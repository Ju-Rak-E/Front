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
    // 401 또는 403 오류 발생 시 토큰 갱신 시도
    if (_shouldRefreshToken(err)) {
      if (_isRefreshing) {
        // 현재 토큰 갱신 중이면 요청을 대기 큐에 추가
        return _addToPendingRequests(
            () => _retryRequest(err.requestOptions, handler));
      }

      _isRefreshing = true;
      await _refreshToken(err.requestOptions, handler);
    } else {
      return handler.next(err);
    }
  }

  // 인증이 필요한 요청인지 확인
  bool _requiresAuth(RequestOptions options) {
    return options.headers['requiresAuth'] == true;
  }

  // Authorization 헤더 추가
  void _addAuthHeader(RequestOptions options, String token) {
    options.headers['Authorization'] = 'Bearer $token';
  }

  // 토큰 갱신이 필요한 오류인지 확인 (401 또는 403)
  bool _shouldRefreshToken(DioException err) {
    return err.response?.statusCode == 401 || err.response?.statusCode == 403;
  }

  // 토큰 갱신을 처리하는 메서드
  Future<void> _refreshToken(
      RequestOptions failedRequest, ErrorInterceptorHandler handler) async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        final newTokens = await _getNewTokens(refreshToken);
        if (newTokens != null) {
          await _saveTokens(newTokens);
          _retryPendingRequests();
          return _retryRequest(failedRequest, handler);
        }
      }
    } catch (e) {
      await _handleTokenRefreshFailure(e);
      return handler
          .next(DioException(requestOptions: failedRequest, error: e));
    } finally {
      _isRefreshing = false;
    }
  }

  // 리프레시 토큰을 사용하여 새로운 액세스 토큰과 리프레시 토큰을 발급받는 메서드
  Future<Map<String, dynamic>?> _getNewTokens(String refreshToken) async {
    final refreshDio = Dio();
    final response = await refreshDio.post(
      '${dotenv.env['BACKEND_BASE_URL']!}/customer/reissue',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      return {
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    }
    return null;
  }

  // 새로운 토큰을 안전한 저장소에 저장
  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    await TokenStorage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );
  }

  // 대기 중인 요청을 재시도하는 메서드
  Future<void> _retryRequest(
      RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    try {
      final retryResponse = await dio.fetch(requestOptions);
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler
          .next(DioException(requestOptions: requestOptions, error: e));
    }
  }

  // 대기 중인 요청들을 재시도
  Future<void> _retryPendingRequests() async {
    for (var request in _pendingRequests) {
      await request();
    }
    _pendingRequests.clear();
  }

  // 토큰 갱신 실패 시 처리
  Future<void> _handleTokenRefreshFailure(dynamic e) async {
    print('토큰 갱신 실패: $e');
    await TokenStorage.deleteTokens();
    await RouteManager.navigateToLogin();
  }

  // 대기 큐에 요청 추가
  Future<void> _addToPendingRequests(Future Function() request) async {
    _pendingRequests.add(request);
  }
}
