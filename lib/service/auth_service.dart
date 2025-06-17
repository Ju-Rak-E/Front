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
  // ApiClient 싱글톤 인스턴스 사용
  // AuthService는 Dio 인스턴스를 직접 가지지 않고, ApiClient를 통해 요청을 보냅니다.
  final ApiClient _apiClient = ApiClient();

  // 카카오 로그인 후 accessToken과 위치 정보를 백엔드로 보내는 함수
  // 메서드 이름을 kakaoLogin으로 변경하고 Position 객체를 받도록 수정
  Future<void> kakaoLogin(String kakaoAccessToken, {Position? position}) async {
    try {
      final String backendUrl = '/customer/login/kakao/android';
      // ApiClient는 이미 baseUrl을 가지고 있으므로, 직접 조합할 필요 없음
      print(
          "로그인 관련 백엔드 URL확인: ${_apiClient.baseUrl}$backendUrl"); // ApiClient의 baseUrl에 직접 접근 가능하도록 수정

      Map<String, dynamic> requestData = {
        'accessToken': kakaoAccessToken,
      };

      // 위치 정보가 있다면 요청 데이터에 추가
      if (position != null) {
        requestData['latitude'] = position.latitude;
        requestData['longitude'] = position.longitude;
        requestData['timestamp'] = position.timestamp?.toIso8601String();
      }

      // 로그: 전송할 데이터 확인
      print("전송할 데이터: $requestData");

      // POST 요청 보내기
      // 로그인 요청은 인증이 필요 없으므로 ApiClient의 publicRequest 메서드 사용
      Response response = await _apiClient.publicRequest(
        // <<<<<< 이 부분 수정됨: publicRequest 사용
        backendUrl,
        method: 'POST', // HTTP 메서드 명시
        data: requestData,
        // publicRequest는 기본적으로 requiresAuth: false 이므로 options.headers에 별도로 설정할 필요 없음
      );

      // 응답 처리
      if (response.statusCode == 200) {
        // 서버 응답에서 JWT 토큰 파싱 및 저장
        final String accessToken = response.data['accessToken']; // 서버 응답 키 확인
        final String refreshToken = response.data['refreshToken']; // 서버 응답 키 확인
        await TokenStorage.saveTokens(
            accessToken: accessToken, refreshToken: refreshToken);
        print('로그인 성공 (AuthService): ${response.data}');
      } else {
        print('로그인 실패 (AuthService): ${response.statusCode}');
        print('응답 본문: ${response.data}');
        throw Exception('Failed to login: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioError 발생 (AuthService): ${e.message}');
      if (e.response != null) {
        print('응답 데이터: ${e.response!.data}');
        print('응답 상태 코드: ${e.response!.statusCode}');
      } else {
        print('응답 없음, 예외 메시지: ${e.message}');
      }
      throw Exception('Failed to connect to backend: ${e.message}');
    } catch (e) {
      print('카카오 로그인 후 백엔드로 보내기 실패 (AuthService): $e');
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  // 다른 인증된 API 호출 예시
  Future<Response> fetchTourArea({
    required String baseYm,
    required String areaCd,
    required String signguCd,
  }) async {
    try {
      // 인증된 API 요청이므로 ApiClient의 authenticatedRequest 메서드 사용
      final response = await _apiClient.authenticatedRequest(
        // <<<<<< 이 부분 수정됨: authenticatedRequest 사용
        '/api/tour/area',
        method: 'GET', // HTTP 메서드 명시
        queryParameters: {
          'baseYm': baseYm,
          'areaCd': areaCd,
          'signguCd': signguCd,
        },
        // authenticatedRequest는 기본적으로 requiresAuth: true 이므로 options.headers에 별도로 설정할 필요 없음
      );
      print('지역 기반 관광지 조회 성공: ${response.data}');
      return response;
    } on DioException catch (e) {
      print('지역 기반 관광지 조회 실패: ${e.message}');
      throw Exception('Failed to fetch tour area: ${e.message}');
    }
  }
}
