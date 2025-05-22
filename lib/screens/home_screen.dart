
import 'package:flutter/material.dart';
import 'result_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("택시요금 거리 계산기")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              child: const Text("지도 보기"),
              onPressed: () {
                final amount = int.tryParse(amountController.text) ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultMapScreen(amount: amount),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
