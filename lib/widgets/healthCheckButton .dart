import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HealthCheckButton extends StatefulWidget {
  const HealthCheckButton({super.key});

  @override
  State<HealthCheckButton> createState() => _HealthCheckButtonState();
}

class _HealthCheckButtonState extends State<HealthCheckButton> {
  String serverStatus = "서버 상태를 확인 중입니다..."; // 초기 상태

  // 서버 상태를 확인하는 메소드
  Future<void> _checkServerConnection() async {
    try {
      // 실제 백엔드 IP 주소 사용 (192.168.x.x는 실제 IP 주소로 바꿔야 함)
      final response =
          await http.get(Uri.parse('http://192.168.219.108:8080/health'));

      // 응답 상태 코드 확인
      print('서버 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          serverStatus = response.body; // 백엔드에서 받은 응답 메시지를 상태에 저장
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _checkServerConnection, // 버튼 클릭 시 서버 상태 확인
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text(
            '서버 상태 확인', // 버튼 텍스트
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 20), // 버튼과 텍스트 사이의 간격 추가
        Text(
          serverStatus, // 서버 상태를 표시
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ],
    );
  }
}
