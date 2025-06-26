import 'package:dio/dio.dart';
import '../service/token_storage.dart';
import '../utils/route_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<Future Function()> _pendingRequests = [];

  DioInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_requiresAuth(options)) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('[✅ Authorization 추가됨]');
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRefreshToken(err)) {
      if (_isRefreshing) {
        return _addToPendingRequests(
            () => _retryRequest(err.requestOptions, handler));
      }

      _isRefreshing = true;
      await _refreshToken(err.requestOptions, handler);
    } else {
      return handler.next(err);
    }
  }

  bool _requiresAuth(RequestOptions options) {
    return options.extra['requiresAuth'] == true;
  }

  bool _shouldRefreshToken(DioException err) {
    return err.response?.statusCode == 401 || err.response?.statusCode == 403;
  }

  Future<void> _refreshToken(
      RequestOptions failedRequest, ErrorInterceptorHandler handler) async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        final newTokens = await _getNewTokens(refreshToken);
        if (newTokens != null) {
          await TokenStorage.saveTokens(
            accessToken: newTokens['accessToken'],
            refreshToken: newTokens['refreshToken'],
          );
          final retryToken = await TokenStorage.getAccessToken();
          failedRequest.headers['Authorization'] = 'Bearer $retryToken';

          final retryResponse = await dio.fetch(failedRequest);
          return handler.resolve(retryResponse);
        }
      }
      throw Exception('Refresh failed');
    } catch (e) {
      await TokenStorage.deleteTokens();
      await RouteManager.navigateToLogin();
      return handler
          .next(DioException(requestOptions: failedRequest, error: e));
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Map<String, dynamic>?> _getNewTokens(String refreshToken) async {
    final refreshDio = Dio();
    final response = await refreshDio.post(
      '${dotenv.env['BACKEND_BASE_URL']!}/customer/reissue',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200) {
      return {
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    }
    return null;
  }

  Future<void> _retryRequest(
      RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (_requiresAuth(requestOptions) && token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    final retryResponse = await dio.fetch(requestOptions);
    return handler.resolve(retryResponse);
  }

  Future<void> _addToPendingRequests(Future Function() request) async {
    _pendingRequests.add(request);
  }
}
