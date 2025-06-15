// 최초 작성자: 김광오
// 수정자 : 김병훈
// 최초 작성일:
// 작성 이유: 카카오 로그인 버튼을 화면 상단에 배치하고 금액 입력 및 지도 보기 기능 구성
import 'package:flutter/material.dart';
import '../widgets/kakao_login.dart';
import '../utils/menu_utils.dart';
import 'result_map_screen.dart';
import 'kakao_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final KakaoLoginService kakaoLoginService = KakaoLoginService();

  @override
  void initState() {
    super.initState();
    kakaoLoginService.checkLoginStatus().then((_) {
      setState(() {
        print('로그인 상태 확인******: ${kakaoLoginService.isLoggedIn}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("택시요금 계산기 + 로그인"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(context, kakaoLoginService),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 지도 영역
          const Flexible(
            flex: 8,
            child: KakaoMapScreen(),
          ),

          // ✅ 금액 입력 UI (스크롤 가능)
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final amount =
                            int.tryParse(amountController.text) ?? 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultMapScreen(amount: amount),
                          ),
                        );
                      },
                      child: const Text("🗺 추가 지도 보기"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
