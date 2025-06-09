import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//최초 작성자: 김병훈
//최초 작성일 : 2025-06-06
//플러터로 로그인 했을시에 백엔드에 accessToken을 보내주기 위한
//Dio라는 HTTP클라이언트 라이브러리 사용

class AuthService {
  final Dio _dio = Dio(); // Dio 인스턴스 생성

  // 카카오 로그인 후 accessToken을 백엔드로 보내는 함수
  Future<void> sendAccessTokenToBackend(String accessToken) async {
    try {
      // 백엔드 URL 설정 (환경 변수에서 로드)
      final String backendUrl =
          dotenv.env['BACKEND_BASE_URL']! + '/customer/login/kakao/android';
      print("로그인 관련 백엔드 URL확인: $backendUrl");

      // 요청 헤더 설정
      Options options = Options(
        headers: {
          'Content-Type': 'application/json', // Content-Type을 명시
        },
      );

      // 로그: 전송할 URL과 데이터 확인
      print("전송할 URL: $backendUrl with 데이터: $accessToken");

      // POST 요청 보내기 (액세스 토큰을 요청 본문에 포함)
      Response response = await _dio.post(
        backendUrl,
        options: options,
        data: {
          'accessToken': accessToken, // 액세스 토큰을 바디에 포함
        },
      );

      // 응답 처리
      if (response.statusCode == 200) {
        // 성공적으로 로그인 처리
        print('로그인 성공(auth_service): ${response.data}');
      } else {
        // 응답 상태 코드가 200이 아닐 경우 처리
        print('로그인 실패(auth_service): ${response.statusCode}');
        print('응답 본문: ${response.data}');
      }
    } catch (e) {
      // DioError 예외 처리
      if (e is DioError) {
        // DioError 예외 처리
        print('DioError 발생: ${e.message}');
        if (e.response != null) {
          print('응답 데이터: ${e.response!.data}');
          print('응답 상태 코드: ${e.response!.statusCode}');
        } else {
          print('응답 없음, 예외 메시지: ${e.message}');
        }
      } else {
        // 일반 예외 처리
        print('카카오 로그인 후 백엔드로 보내기 실패(auth_service)[]: $e');
      }
    }
  }
}
