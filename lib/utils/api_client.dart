import 'package:dio/dio.dart';
import 'dio_interceptor.dart';

/// API 요청을 처리하는 클라이언트 클래스
/// 
/// Dio를 사용하여 HTTP 요청을 처리하며,
/// 인증이 필요한 요청과 필요없는 요청을 구분하여 처리합니다.
class ApiClient {
  late final Dio _dio;
  // 백엔드 API의 기본 URL
  static const String baseUrl = 'YOUR_BACKEND_API_URL'; // TODO: 실제 백엔드 API URL로 변경 필요

  ApiClient() {
    // Dio 인스턴스 생성 및 기본 설정
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),  // 연결 타임아웃
      receiveTimeout: const Duration(seconds: 3),  // 응답 수신 타임아웃
    ));

    // 토큰 관리를 위한 인터셉터 추가
    _dio.interceptors.add(DioInterceptor(_dio));
  }

  /// 인증이 필요한 API 요청을 처리하는 메서드
  /// 
  /// [path] API 엔드포인트 경로
  /// [method] HTTP 메서드 (기본값: 'GET')
  /// [data] 요청 본문 데이터
  /// [queryParameters] URL 쿼리 파라미터
  /// 
  /// Returns: API 응답
  Future<Response> authenticatedRequest(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        method: method,
        headers: {'requiresAuth': true},  // 인터셉터에서 토큰 추가를 위한 플래그
      ),
    );
  }

  /// 인증이 필요없는 API 요청을 처리하는 메서드
  /// 
  /// [path] API 엔드포인트 경로
  /// [method] HTTP 메서드 (기본값: 'GET')
  /// [data] 요청 본문 데이터
  /// [queryParameters] URL 쿼리 파라미터
  /// 
  /// Returns: API 응답
  Future<Response> publicRequest(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(method: method),
    );
  }
} 