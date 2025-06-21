import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../utils/token_storage.dart'; // TokenStorage 임포트

/// 카카오 로그인 인증 처리를 담당하는 서비스 클래스
/// 카카오 SDK와의 통신 및 기본 로그인 상태 관리를 수행합니다.
class KakaoLoginService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoading = false; // 로그인 처리 중 상태를 나타냄

  /// 앱 내 저장된 JWT 토큰을 확인하여 로그인 상태를 반환합니다.
  Future<bool> checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken(); // SecureStorage에서 토큰 확인
    return token != null; // 토큰이 존재하면 로그인된 상태로 간주
  }

  /// 카카오 로그인을 수행합니다.
  ///
  /// [onSuccess] 카카오 인증 성공 후, 카카오 Access Token을 인자로 받는 콜백 함수.
  /// 이 콜백을 통해 백엔드 연동 로직을 처리합니다.
  Future<void> loginWithKakao(
      {required Function(String kakaoAccessToken) onSuccess}) async {
    if (isLoading) return; // 이미 로그인 처리 중이라면 중복 실행 방지
    isLoading = true; // 로그인 처리 시작

    try {
      final installed = await isKakaoTalkInstalled(); // 카카오톡 설치 여부 확인
      OAuthToken token;

      if (installed) {
        // 카카오톡이 설치되어 있으면 카카오톡으로 로그인 시도
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 없으면 카카오 계정(웹)으로 로그인 시도
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('✅ 카카오 SDK 로그인 성공: ${token.accessToken}');

      // 카카오 인증 성공 후, 외부에서 정의된 onSuccess 콜백을 호출하여 Access Token 전달
      // 이 콜백에서 백엔드 로그인 처리가 진행됩니다.
      await onSuccess(token.accessToken); // await 추가하여 비동기 콜백 완료 대기

      // 사용자 정보 가져오기 (선택 사항, 로그용)
      final user = await UserApi.instance.me();
      print('👤 카카오 사용자 ID: ${user.id}');
      print('👤 카카오 이메일: ${user.kakaoAccount?.email}');
      print('👤 카카오 닉네임: ${user.kakaoAccount?.profile?.nickname}');
    } catch (e) {
      print('❌ 카카오 SDK 로그인 실패: $e');
      rethrow; // 에러를 다시 던져 호출자(LoginPage)에서 상세 처리
    } finally {
      isLoading = false; // 로그인 처리 완료
    }
  }

  /// 카카오 및 앱 로그아웃을 처리합니다.
  ///
  /// 카카오 세션을 끊고, 앱 내에 저장된 JWT 토큰을 삭제합니다.
  Future<void> logout() async {
    print('🔓 로그아웃 시도');
    try {
      await UserApi.instance.logout(); // 카카오 SDK 로그아웃
      await TokenStorage.deleteTokens(); // SecureStorage에서 JWT 토큰 삭제
      print('🔓 카카오 및 앱 로그아웃 성공');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
      rethrow; // 에러를 다시 던져 호출자에서 처리
    }
  }
}
