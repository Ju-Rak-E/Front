import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'route_manager.dart';

/// Dio HTTP 클라이언트의 인터셉터
///
/// API 요청에 자동으로 인증 토큰을 추가하고,
/// 토큰 만료 시 자동으로 갱신을 시도합니다.
class DioInterceptor extends Interceptor {
  final Dio dio;
  // 토큰 갱신 중인지 확인하는 플래그
  bool _isRefreshing = false;
  // 토큰 갱신 대기 중인 요청들을 저장하는 큐
  final List<Future Function()> _pendingRequests = [];

  DioInterceptor(this.dio);

  /// 요청을 보내기 전에 실행되는 메서드
  ///
  /// 인증이 필요한 요청의 경우 저장된 토큰을 Request Body에 추가합니다.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // requiresAuth 헤더가 true인 경우에만 토큰 추가
    if (options.headers['requiresAuth'] == true) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        // Bearer 토큰 형식으로 Authorization 헤더 대신 바디에 토큰 추가
        options.data = {
          'accessToken': token, // 액세스 토큰을 Request Body에 포함
        };
        // 기존 Authorization 헤더 제거
        options.headers.remove('Authorization');
      }
    }
    // 임시로 사용한 requiresAuth 헤더 제거
    options.headers.remove('requiresAuth');
    return handler.next(options);
  }

  /// 에러 발생 시 실행되는 메서드
  ///
  /// 401 Unauthorized 에러 발생 시 토큰 갱신을 시도합니다.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 이미 토큰 갱신 중이면 대기
      if (_isRefreshing) {
        // 현재 요청을 대기 큐에 추가
        return _addToPendingRequests(
            () => _retryRequest(err.requestOptions, handler));
      }

      _isRefreshing = true;

      try {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken != null) {
          // 리프레시 토큰으로 새로운 토큰 발급 요청
          final response = await dio.post(
            '/auth/refresh', // 백엔드의 토큰 갱신 엔드포인트
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            // 새로운 액세스 토큰과 리프레시 토큰을 안전한 저장소에 저장
            await TokenStorage.saveTokens(
              accessToken: response.data['access_token'],
              refreshToken: response.data['refresh_token'], // 새로운 리프레시 토큰
            );

            // 대기 중인 모든 요청 재시도
            for (var request in _pendingRequests) {
              await request();
            }
            _pendingRequests.clear();

            // 현재 실패한 요청 재시도
            return _retryRequest(err.requestOptions, handler);
          }
        }
      } catch (e) {
        // 토큰 갱신 실패 시 로그아웃 처리
        await TokenStorage.deleteTokens();
        // 로그인 화면으로 이동
        await RouteManager.navigateToLogin();
      } finally {
        _isRefreshing = false;
      }
    }
    return handler.next(err);
  }

  /// 실패한 요청을 재시도하는 메서드
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final retryResponse = await dio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
        ),
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      return handler.resolve(retryResponse);
    } catch (e) {
      return handler.next(DioException(
        requestOptions: requestOptions,
        error: e,
      ));
    }
  }

  /// 대기 중인 요청 큐에 요청을 추가하는 메서드
  Future<void> _addToPendingRequests(Future Function() request) async {
    _pendingRequests.add(request);
  }
}
