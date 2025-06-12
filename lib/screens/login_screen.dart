import 'package:flutter/material.dart';
import '../widgets/kakao_login.dart'; // KakaoLoginService를 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // LoginPage로 시작
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoLoginService kakaoLoginService =
      KakaoLoginService(); // KakaoLoginService 객체 생성

  @override
  void initState() {
    super.initState();
    kakaoLoginService.checkLoginStatus(); // 앱 시작 시 자동 로그인 체크
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 정보를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0), // 배경 색상
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
        children: [
          //*************상단 구역*****************
          Container(
            alignment: Alignment.center,
            height: (screenHeight / 3), // 화면 상단 영역을 3등분 한 1/3으로 설정
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
                children: [
                  // "계획짤 시간에 \n 벌써 도착!" 텍스트
                  Text(
                    '계획짤 시간에 \n벌써 도착!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // 화면 너비의 6%로 폰트 크기 설정
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // "우리는 얼마GO" 텍스트
                  SizedBox(height: 10), // 두 텍스트 간의 간격
                  Text(
                    '우리는 얼마GO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          screenWidth * 0.08, // 화면 너비의 8%로 폰트 크기 설정 (크게 설정)
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //*************카카오 로그인 구역*****************
          SizedBox(height: 10), // 타이틀과 버튼 간격
          Container(
            child: ElevatedButton(
              onPressed: () async {
                // 카카오 로그인 처리 함수 호출
                await _loginWithKakao(context); // 카카오 로그인 함수 호출
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF9E000), // 카카오 버튼 색상
                minimumSize: Size(double.infinity, 50), // 버튼 너비 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 버튼의 모서리 둥글게
                ),
              ),
              child: Text(
                '카카오로 시작하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          //*************R의 구역*****************
          // 버튼과 로고 간격
          // 중간 구분선 추가 (구분선은 실제 UI에서는 안 보이게 하므로 제거)
          Container(
            color: Colors.red, // 중간 구분선
            height: 1,
            width: screenWidth,
          ),
          // Spacer: R 텍스트가 하단에 위치하게 하기 위해 사용
          Spacer(),
          // 하단 R 텍스트 표시 (이미지 등 추가 가능)
          Container(
            child: Align(
              alignment: Alignment.bottomCenter, // 하단 중앙 정렬
              child: Text(
                'R',
                style: TextStyle(
                  fontSize:
                      screenHeight * 0.5, // 화면 높이의 30%로 폰트 크기 설정 (좀 더 크게 설정)
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카카오 로그인 처리 함수
  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      // KakaoLoginService의 loginWithKakao 메서드를 호출하여 카카오 로그인 처리
      await kakaoLoginService.loginWithKakao();

      // 로그인 성공 후, 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('카카오 로그인 실패: $e');
      // 로그인 실패 시 메시지 표시 또는 다른 처리를 할 수 있습니다
    }
  }
}
