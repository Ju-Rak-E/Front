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
  String serverStatus = "서버 상태를 확인 중입니다...";

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  // 서버 상태를 확인하는 메소드
  Future<void> _checkServerConnection() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.2:8080/health'));
      print('서버 응답 상태: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          serverStatus = "서버 연결 성공!";
        });
      } else {
        setState(() {
          serverStatus = "서버 연결 실패: 상태 코드 ${response.statusCode}";
        });
      }
    } catch (e) {
      print('서버 연결 예외: $e');
      setState(() {
        serverStatus = "서버 연결 실패: $e";
      });
    }
  }

  // 새로운 HealthCheckButton 추가
  Widget _healthCheckButton() {
    return ElevatedButton(
      onPressed: _checkServerConnection, // 버튼 클릭 시 서버 상태 확인
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text(
        '서버 상태 확인', // 버튼 텍스트
        style: TextStyle(color: Colors.white),
      ),
    );
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
            const SizedBox(height: 10),

            // 서버 상태 출력
            Text(
              serverStatus,
              style: const TextStyle(color: Colors.blue),
            ),

            const SizedBox(height: 20),

            // 서버 상태 확인 버튼 추가
            _healthCheckButton(),

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
