import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'route_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Dio HTTP 클라이언트의 인터셉터
///
/// API 요청에 자동으로 인증 토큰을 추가하고,
/// 토큰 만료 시 자동으로 갱신을 시도합니다.
class DioInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false; // 토큰 갱신 중인지 여부를 확인하는 플래그
  final List<Future Function()> _pendingRequests =
      []; // 토큰 갱신 대기 중인 요청들을 저장하는 큐

  DioInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 인증이 필요한 요청에만 토큰 추가
    if (_requiresAuth(options)) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        _addAuthHeader(options, token);
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRefreshToken(err)) {
      if (_isRefreshing) {
        // 토큰 갱신 중이면 요청을 대기 큐에 추가
        return _addToPendingRequests(
            () => _retryRequest(err.requestOptions, handler));
      }

      _isRefreshing = true;
      await _refreshToken(err.requestOptions, handler);
    } else {
      return handler.next(err);
    }
  }

  /// 인증 필요 여부: headers 또는 extra에 명시 가능
  bool _requiresAuth(RequestOptions options) {
    return options.headers['requiresAuth'] == true ||
        options.extra['requiresAuth'] == true;
  }

  void _addAuthHeader(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
    print('[Authorization 헤더 추가됨] Bearer $token');
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
          await _saveTokens(newTokens);

          // 🔽 꼭 최신 토큰을 다시 읽어야 함
          await Future.delayed(Duration(milliseconds: 100));
          final retryToken = await TokenStorage.getAccessToken();
          failedRequest.headers['Authorization'] = 'Bearer $retryToken';

          final retryResponse = await dio.fetch(failedRequest);
          return handler.resolve(retryResponse);
        }
      }

      // refreshToken 자체가 없거나 실패
      throw Exception('Refresh failed');
    } catch (e) {
      await _handleTokenRefreshFailure(e);
      return handler
          .next(DioException(requestOptions: failedRequest, error: e));
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Map<String, dynamic>?> _getNewTokens(String refreshToken) async {
    final refreshDio = Dio();
    refreshDio.options.headers['Content-Type'] = 'application/json';

    try {
      final response = await refreshDio.post(
        '${dotenv.env['BACKEND_BASE_URL']!}/customer/reissue',
        data: {
          'refreshToken': refreshToken, // ✅ Body에만 포함
        },
      );

      if (response.statusCode == 200) {
        return {
          'accessToken': response.data['accessToken'],
          'refreshToken': response.data['refreshToken'],
        };
      } else {
        print('⚠️ 리프레시 실패 응답: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ Dio 리프레시 예외: ${e.response?.statusCode}, ${e.response?.data}');
    }

    return null;
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    print('[🧪 새 accessToken 저장 중]: ${tokens['accessToken']}');
    await TokenStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );
    print('[✅ 토큰 저장 완료]');
  }

  Future<void> _retryRequest(
      RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    try {
      // 재요청 시에도 인증 필요하면 토큰 다시 추가
      final token = await TokenStorage.getAccessToken();
      if (_requiresAuth(requestOptions) && token != null) {
        requestOptions.headers['Authorization'] = 'Bearer $token';
      }

      final retryResponse = await dio.fetch(requestOptions);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler
          .next(DioException(requestOptions: requestOptions, error: e));
    }
  }

  Future<void> _retryPendingRequests() async {
    for (var request in _pendingRequests) {
      await request();
    }
    _pendingRequests.clear();
  }

  Future<void> _handleTokenRefreshFailure(dynamic e) async {
    print('토큰 갱신 실패: $e');
    await TokenStorage.deleteTokens();
    await RouteManager.navigateToLogin();
  }

  Future<void> _addToPendingRequests(Future Function() request) async {
    _pendingRequests.add(request);
  }
}
