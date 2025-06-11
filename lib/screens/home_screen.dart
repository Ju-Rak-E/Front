// 최초 작성자: 김광오
// 수정자 : 김병훈
// 최초 작성일:
// 작성 이유: 카카오 로그인 버튼을 화면 상단에 배치하고 금액 입력 및 지도 보기 기능 구성

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'result_map_screen.dart';
import '../widgets/kakao_login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("택시요금 계산기 + 로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 카카오 로그인 버튼
            const KakaoLoginButton(),
            const SizedBox(height: 10), // 카카오 로그인 버튼과 다른 요소 간의 간격

            const SizedBox(height: 30), // 버튼과 다음 항목 간의 간격

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
