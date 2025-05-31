// 최초 작성자: 김병훈
// 최초 작성일: 2025-05-31
// 작성 이유: Flutter에서 카카오 로그인 버튼을 재사용 가능한 위젯으로 분리

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key});

  Future<void> _loginWithKakao() async {
    try {
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('✅ 로그인 성공: $token');

      final user = await UserApi.instance.me();
      print('👤 사용자 ID: ${user.id}');
      print('👤 이메일: ${user.kakaoAccount?.email}');
      print('👤 닉네임: ${user.kakaoAccount?.profile?.nickname}');
    } catch (e) {
      print('❌ 로그인 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loginWithKakao,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
      child: const Text(
        '카카오로 로그인',
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
