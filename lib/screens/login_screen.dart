import 'package:flutter/material.dart';
import '../service/auth_service.dart'; // AuthService 임포트
import '../service/kakao_login_service.dart'; // KakaoLoginService 임포트
import '../utils/route_manager.dart'; // RouteManager 임포트

/// 앱의 로그인 화면
/// 카카오 로그인 및 자동 로그인을 처리합니다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin(); // 자동 로그인 상태 확인
  }

  /// 앱 시작 시 저장된 JWT 토큰을 확인하여 자동 로그인 처리
  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await _kakaoLoginService.checkLoginStatus();
    if (isLoggedIn && mounted) {
      RouteManager.navigateToHome();
    }
  }

  /// 카카오 로그인 프로세스를 시작하는 함수
  Future<void> _loginWithKakao() async {
    try {
      await _kakaoLoginService.loginWithKakao(
        onSuccess: (kakaoAccessToken) async {
          await _authService.kakaoLogin(kakaoAccessToken);
          if (mounted) {
            RouteManager.navigateToHome();
          }
        },
      );
    } catch (e) {
      print('카카오 로그인 또는 백엔드 통신 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // ✅ 배경 이미지 + ShaderMask 오버레이
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.1),
                ],
              ).createShader(bounds),
              blendMode: BlendMode.srcATop,
              child: Image.asset(
                'assets/images/splashImage.png',
                fit: BoxFit.cover,
                width: screenWidth,
                height: screenHeight,
              ),
            ),

            // ✅ 내용물
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ 상단 텍스트
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      children: [
                        Text(
                          '계획짤 시간에\n벌써 도착!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'BMDOHYEON',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '얼마GO',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 100,
                            fontFamily: 'BMDOHYEON',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ✅ 카카오 로그인 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _kakaoLoginService.isLoading
                            ? null
                            : _loginWithKakao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9E000),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _kakaoLoginService.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text(
                                '카카오로 시작하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
