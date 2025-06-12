// 최초 작성자: 김광오
// 수정자 : 김병훈
// 최초 작성일:
// 작성 이유: 카카오 로그인 버튼을 화면 상단에 배치하고 금액 입력 및 지도 보기 기능 구성

import 'package:flutter/material.dart';
import 'result_map_screen.dart';
import '../widgets/kakao_login.dart'; // KakaoLoginService import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final KakaoLoginService kakaoLoginService = KakaoLoginService(); // 로그인 상태 관리

  @override
  void initState() {
    super.initState();
    kakaoLoginService.checkLoginStatus().then((_) {
      setState(() {
        // 로그인 상태 확인 후 UI 갱신
        print('로그인 상태 확인******: ${kakaoLoginService.isLoggedIn}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈스크린 화면"),
        actions: [
          // 로그인 상태에 따라 우측 상단에 로그아웃 텍스트 표시
          kakaoLoginService.isLoggedIn
              ? GestureDetector(
                  onTap: () async {
                    // 로그아웃 처리
                    await kakaoLoginService.logout();
                    setState(() {}); // 상태 갱신

                    //로그아웃 후 로그인 페이지로 이동
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 60,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(), // 로그인 안 됐을 때는 빈 공간
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "💰 금액 입력 후 지도 보기",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // 텍스트와 입력 필드 간의 간격

            // 금액 입력 필드
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "금액 입력 (예: 10000)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20), // 금액 입력 필드와 버튼 간의 간격

            // 지도 보기 버튼
            ElevatedButton(
              onPressed: () {
                final amount =
                    int.tryParse(amountController.text) ?? 0; // 금액 입력 값 처리
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultMapScreen(
                        amount: amount), // 금액을 ResultMapScreen으로 전달
                  ),
                );
              },
              child: const Text("🗺 지도 보기"),
            ),
          ],
        ),
      ),
    );
  }
}
