// lib/service/auth_service.dart

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart'; // Position 타입 사용을 위해 임포트
import '../utils/api_client.dart'; // ApiClient 임포트 (수정됨)
import '../utils/token_storage.dart'; // TokenStorage 임포트

//최초 작성자: 김병훈
//최초 작성일 : 2025-06-06
//플러터로 로그인 했을시에 백엔드에 accessToken을 보내주기 위한
//Dio라는 HTTP클라이언트 라이브러리 사용

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// ✅ 카카오 로그인 요청 (인증 필요 없음)
  Future<void> kakaoLogin(String kakaoAccessToken, {Position? position}) async {
    try {
      final String backendUrl = '/customer/login/kakao/android';

      Map<String, dynamic> requestData = {
        'accessToken': kakaoAccessToken,
      };

      if (position != null) {
        requestData['latitude'] = position.latitude;
        requestData['longitude'] = position.longitude;
        requestData['timestamp'] = position.timestamp?.toIso8601String();
      }

      print("[🔐 로그인 요청] URL: $_apiClient.baseUrl$backendUrl");
      print("[📤 보낼 데이터] $requestData");

      Response response = await _apiClient.publicRequest(
        backendUrl,
        method: 'POST',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final String accessToken = response.data['accessToken'];
        final String refreshToken = response.data['refreshToken'];
        await TokenStorage.saveTokens(
            accessToken: accessToken, refreshToken: refreshToken);
        print('[✅ 로그인 성공] 토큰 저장 완료');
      } else {
        print('[❌ 로그인 실패] 상태 코드: ${response.statusCode}');
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      print('[🚫 로그인 요청 실패] DioException: ${e.message}');
      if (e.response != null) {
        print('[📥 서버 응답] ${e.response!.data}');
      }
      throw Exception('Login error: ${e.message}');
    }
  }

  /// ✅ 인증된 관광지 조회 (예시)
  Future<Response> fetchTourArea({
    required String baseYm,
    required String areaCd,
    required String signguCd,
  }) async {
    try {
      final response = await _apiClient.authenticatedRequest(
        '/api/tour/area',
        method: 'GET',
        queryParameters: {
          'baseYm': baseYm,
          'areaCd': areaCd,
          'signguCd': signguCd,
        },
      );
      print('[✅ 관광지 조회 성공] ${response.data}');
      return response;
    } on DioException catch (e) {
      print('[❌ 관광지 조회 실패] ${e.message}');
      throw Exception('Tour area fetch failed');
    }
  }

  /// ✅ 택시 요금 기반 반경 조회 (중요: 인증 필요)
  Future<Response> estimateRadius({
    required double latitude,
    required double longitude,
    required int fare,
  }) async {
    try {
      // 로그로 요청 정보 확인
      print('[📡 반경 요청] lat: $latitude, lng: $longitude, fare: $fare');

      // 토큰 확인 로그 추가
      final token = await TokenStorage.getAccessToken();
      print('[🔑 현재 저장된 액세스 토큰] $token');

      final response = await _apiClient.authenticatedRequest(
        '/api/taxi/estimate-radius',
        method: 'POST',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'fare': fare,
        },
      );

      print('[✅ 반경 조회 성공] ${response.data}');
      return response;
    } on DioException catch (e) {
      print('[❌ 반경 조회 실패] DioException: ${e.message}');
      if (e.response != null) {
        print('[📥 서버 응답] ${e.response!.data}');
      }
      throw Exception('Failed to estimate radius: ${e.message}');
    }
  }
}
