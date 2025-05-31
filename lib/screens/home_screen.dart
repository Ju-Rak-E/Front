// 최초 작성자: 김광오
// 수정자 : 김병훈
// 최초 작성일:
// 작성 이유: 카카오 로그인 버튼을 화면 상단에 배치하고 금액 입력 및 지도 보기 기능 구성

import 'package:flutter/material.dart';
import 'result_map_screen.dart';
import '../widgets/kakao_login.dart'; // ✅ 위젯 import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("택시요금 계산기 + 로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ 상단에 카카오 로그인 버튼 배치
            const KakaoLoginButton(),
            const SizedBox(height: 30),

            const Text(
              "💰 금액 입력 후 지도 보기",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "금액 입력 (예: 10000)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text) ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultMapScreen(amount: amount),
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
