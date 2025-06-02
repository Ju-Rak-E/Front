// 최초 작성자: 김병훈
// 최초 작성일 : 2025-05-25
// 최종 수정일: 2025-06-02
// 목적: Flutter에서 카카오 로그인 처리 + JWT secure 저장 + 자동 로그인 + UI 상태 반영

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KakaoLoginButton extends StatefulWidget {
  const KakaoLoginButton({super.key});

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  // ✅ FlutterSecureStorage로 JWT를 안전하게 저장
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ✅ 로그인 여부를 나타내는 상태값
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 앱 시작 시 JWT 존재 여부로 자동 로그인 처리
  }

  // ✅ 저장된 accessToken이 있으면 로그인 상태로 인식
  Future<void> _checkLoginStatus() async {
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  // ✅ 카카오 로그인 처리 + 서버에 accessToken 전달 + JWT 저장
  Future<void> _loginWithKakao() async {
    try {
      // 카카오톡 앱이 설치되어 있으면 앱으로 로그인, 없으면 계정 로그인
      final installed = await isKakaoTalkInstalled();
      final token = installed
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('✅ 카카오 로그인 성공: $token');

      // Spring 서버에 Kakao accessToken 전달
      final response = await http.post(
        Uri.parse('http://192.168.219.104:8080/customer/login/kakao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': token.accessToken}),
      );

      // 서버 응답이 성공이면 JWT 저장
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: json['accessToken']);
        await storage.write(key: 'refreshToken', value: json['refreshToken']);

        // 상태 변경 → 로그인 완료로 표시
        setState(() {
          isLoggedIn = true;
        });

        // 사용자 정보 디버깅 출력
        final user = await UserApi.instance.me();
        print('👤 사용자 ID: ${user.id}');
        print('👤 이메일: ${user.kakaoAccount?.email}');
        print('👤 닉네임: ${user.kakaoAccount?.profile?.nickname}');
      } else {
        _showAlert('로그인에 실패했습니다'); // 서버에서 토큰 처리 실패 시
      }
    } catch (e) {
      _showAlert('로그인에 실패했습니다'); // 예외 발생 시
    }
  }

  // ✅ 로그아웃 처리: 카카오 로그아웃 + 로컬 JWT 삭제
  Future<void> _logout() async {
    await UserApi.instance.logout();
    await storage.deleteAll(); // JWT 제거
    setState(() {
      isLoggedIn = false;
    });
  }

  // ✅ Alert 메시지 UI
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ✅ UI: 로그인/로그아웃 버튼 표시
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoggedIn ? _logout : _loginWithKakao, // 상태에 따라 동작 다르게
      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
      child: Text(
        isLoggedIn ? '로그아웃' : '카카오로 로그인',
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
