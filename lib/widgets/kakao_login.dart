// 최초 작성자: 김병훈
// 최초 작성일 : 2025-05-25
// 최종 수정일: 2025-06-02
// 목적: Flutter에서 카카오 로그인 처리 + JWT secure 저장 + 자동 로그인 + UI 상태 반영
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../service/auth_service.dart';

class KakaoLoginService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoggedIn = false;
  bool isLoading = false;

  // 저장된 accessToken을 확인하여 자동 로그인 상태 처리
  Future<void> checkLoginStatus() async {
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      isLoggedIn = true;
    }
  }

  // 카카오 로그인 처리
  Future<void> loginWithKakao() async {
    if (isLoading) return; // 이미 로그인 중이라면 중복 클릭 방지
    isLoading = true;

    try {
      final installed = await isKakaoTalkInstalled();
      final token = installed
          ? await UserApi.instance.loginWithKakaoTalk() // 카카오톡으로 로그인
          : await UserApi.instance.loginWithKakaoAccount(); // 카카오 계정으로 로그인

      print('✅ 카카오 로그인 성공: ${token.accessToken}');
      await storage.write(key: 'accessToken', value: token.accessToken);
      isLoggedIn = true;

      AuthService().sendAccessTokenToBackend(token.accessToken);

      final user = await UserApi.instance.me();
      print('👤 사용자 ID: ${user.id}');
      print('👤 이메일: ${user.kakaoAccount?.email}');
      print('👤 닉네임: ${user.kakaoAccount?.profile?.nickname}');
    } catch (e) {
      print('❌ 로그인 실패: $e');
    } finally {
      isLoading = false;
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    print('🔓 로그아웃 시도');
    await UserApi.instance.logout();
    await storage.deleteAll(); // JWT 제거
    isLoggedIn = false;
  }
}
