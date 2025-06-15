import 'package:flutter/material.dart';
import '../widgets/kakao_login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoLoginService kakaoLoginService = KakaoLoginService();

  @override
  void initState() {
    super.initState();
    kakaoLoginService.checkLoginStatus();
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
                        const SizedBox(height: 10), // 위아래 여백
                        Text(
                          '얼마GO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 100, // ✅ 고정 px 사이즈
                            fontFamily: 'BMDOHYEON',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  SizedBox(height: 120),

                  // ✅ 카카오 로그인 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _loginWithKakao(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9E000),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      await kakaoLoginService.loginWithKakao();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('카카오 로그인 실패: $e');
    }
  }
}
