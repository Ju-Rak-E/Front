import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// 카카오 로그인을 수행하는 메서드
  Future<void> _handleKakaoLogin() async {
    try {
      // 카카오톡으로 로그인 시도
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 설치되어 있지 않은 경우 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }
      
      // 로그인 성공 시 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      print('카카오 로그인 성공: ${user.kakaoAccount?.profile?.nickname}');
      
      // TODO: 백엔드 서버에 카카오 액세스 토큰 전송하여 JWT 토큰 발급받기
      
    } catch (error) {
      print('카카오 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '로그인이 필요합니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleKakaoLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('카카오로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
} 