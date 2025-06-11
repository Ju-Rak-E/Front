// 최초 작성자: 김병훈
// 최초 작성일 : 2025-05-25
// 최종 수정일: 2025-06-02
// 목적: Flutter에서 카카오 로그인 처리 + JWT secure 저장 + 자동 로그인 + UI 상태 반영
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../service/auth_service.dart';

class KakaoLoginButton extends StatefulWidget {
  const KakaoLoginButton({super.key});

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoggedIn = false;
  bool isLoading = false; // 로그인 중 여부를 추적하는 변수

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 앱 시작 시 JWT 존재 여부로 자동 로그인 처리
  }

  // 저장된 accessToken을 확인하여 자동 로그인 상태 처리
  Future<void> _checkLoginStatus() async {
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  // 카카오 로그인 처리
  Future<void> _loginWithKakao() async {
    if (isLoading) return; // 이미 로그인 중이라면 중복 클릭 방지
    setState(() {
      isLoading = true; // 로그인 중 상태 설정
    });

    try {
      // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오 계정으로 로그인
      final installed = await isKakaoTalkInstalled();
      final token = installed
          ? await UserApi.instance.loginWithKakaoTalk() // 카카오톡으로 로그인
          : await UserApi.instance.loginWithKakaoAccount(); // 카카오 계정으로 로그인

      print('✅ 카카오 로그인 성공: ${token.accessToken}');

      // 로그인 후 받은 accessToken을 로컬에 저장
      await storage.write(key: 'accessToken', value: token.accessToken);
      setState(() {
        isLoggedIn = true; // 로그인 성공 시 상태 업데이트
      });

      // 카카오 로그인 후 백엔드로 accessToken 보내기
      AuthService().sendAccessTokenToBackend(token.accessToken);

      // 로그인한 사용자 정보 출력 (UI에서 확인용)
      final user = await UserApi.instance.me();
      print('👤 사용자 ID: ${user.id}');
      print('👤 이메일: ${user.kakaoAccount?.email}');
      print('👤 닉네임: ${user.kakaoAccount?.profile?.nickname}');

      // 사용자 정보 UI에 반영하기 위한 처리
      _showAlert("로그인 성공! 사용자 ID: ${user.id}");
    } catch (e) {
      print('❌ 로그인 실패: $e');
      _showAlert('로그인에 실패했습니다');
    } finally {
      setState(() {
        isLoading = false; // 로그인 후 로딩 상태 해제
      });
    }
  }

  // 로그아웃 처리
  Future<void> _logout() async {
    print('🔓 로그아웃 시도');
    await UserApi.instance.logout();
    await storage.deleteAll(); // JWT 제거
    setState(() {
      isLoggedIn = false;
    });
  }

  // 알림창을 띄우는 함수
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoggedIn || isLoading
          ? _logout
          : _loginWithKakao, // 로그인 상태 또는 로딩 중일 때는 로그아웃, 그 외에는 로그인
      child: isLoggedIn
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: Colors.yellow[700], // 로그아웃 버튼 색상
              child: const Text(
                '로그아웃', // 로그아웃 텍스트
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            )
          : Container(
              width: 250, // 로그인 버튼 너비 설정
              height: 60, // 로그인 버튼 높이 설정
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/kakao_login_medium.png'), // 로그인 이미지
                  fit: BoxFit.cover, // 이미지를 버튼 크기에 맞게 채우기
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // 로딩 중에는 로딩 표시
                  : null,
            ),
    );
  }
}
