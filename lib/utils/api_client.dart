import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dio_interceptor.dart';

/// API 요청을 처리하는 클라이언트 클래스 (싱글톤)
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _baseUrl = dotenv.env['BACKEND_BASE_URL']!; // 환경 변수에서 로드

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl, // 내부 _baseUrl 사용
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: Headers.jsonContentType,
    ));

    _dio.interceptors.add(DioInterceptor(_dio));
  }

  late final Dio _dio;
  late final String _baseUrl; // <<<<<< 이 부분 추가: baseUrl을 private 변수로 선언

  // <<<<<< 이 부분 추가: baseUrl에 대한 public getter >>>>>
  String get baseUrl => _baseUrl;

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
        headers: {'requiresAuth': true},
      ),
    );
  }

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
