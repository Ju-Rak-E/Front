import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../service/token_storage.dart'; // JWT 토큰 저장/삭제용

/// 카카오 로그인 인증 처리를 담당하는 서비스 클래스
class KakaoLoginService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoading = false;

  /// 앱 내 저장된 JWT 토큰 존재 여부로 로그인 상태 판단
  Future<bool> checkLoginStatus() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }

  /// 카카오 로그인 수행
  ///
  /// [onSuccess]: 카카오 accessToken을 전달하여 백엔드 인증 처리하는 콜백
  Future<void> loginWithKakao({
    required Function(String kakaoAccessToken) onSuccess,
  }) async {
    if (isLoading) return;
    isLoading = true;

    try {
      final installed = await isKakaoTalkInstalled();
      OAuthToken token;

      if (installed) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('✅ 카카오 SDK 로그인 성공: ${token.accessToken}');
      await onSuccess(token.accessToken); // 백엔드 인증 요청

      final user = await UserApi.instance.me();
      print('👤 카카오 사용자 ID: ${user.id}');
      print('👤 카카오 이메일: ${user.kakaoAccount?.email}');
      print('👤 카카오 닉네임: ${user.kakaoAccount?.profile?.nickname}');
    } catch (e) {
      print('❌ 카카오 SDK 로그인 실패: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// 카카오 로그아웃 + 앱 JWT 토큰 삭제
  Future<void> logout() async {
    print('🔓 로그아웃 시도');

    try {
      // ✅ accessToken 유효성 검사
      await UserApi.instance.accessTokenInfo();

      // ✅ 유효할 경우만 logout 호출
      await UserApi.instance.logout();
      print('✅ 카카오 SDK 로그아웃 완료');
    } on KakaoClientException catch (e) {
      print('ℹ️ Kakao SDK에 토큰 없음 또는 이미 만료됨: ${e.message}');
    } catch (e) {
      print('❗ 카카오 로그아웃 중 알 수 없는 오류 발생: $e');
    }

    await TokenStorage.deleteTokens();
    print('✅ 앱 내 JWT 토큰 삭제 완료');
  }
}
