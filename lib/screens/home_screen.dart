// lib/screens/home_screen.dart

// 수정자 : 김병훈 (2025-06-17)
// 목적: 홈 화면에서 인증 필요한 API 호출 및 로그아웃 기능 통합.
//      카카오 로그인 버튼은 로그인 화면(LoginPage)에서만 처리하도록 변경.
//      택시 요금 계산 및 지도 보기 기능 유지.

import 'package:flutter/material.dart';
import '../service/auth_service.dart'; // AuthService 임포트
import '../service/kakao_login_service.dart'; // KakaoLoginService 임포트
import '../utils/route_manager.dart'; // RouteManager 임포트
import '../utils/menu_utils.dart'; // menu_utils 임포트 (showAppMenu 함수)
import 'result_map_screen.dart'; // ResultMapScreen 임포트
import 'kakao_map_screen.dart'; // KakaoMapScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final AuthService _authService = AuthService(); // AuthService 인스턴스
  final KakaoLoginService _kakaoLoginService =
      KakaoLoginService(); // KakaoLoginService 인스턴스

  String _tourAreaResult = "아직 조회되지 않았습니다."; // API 호출 결과 표시

  @override
  void initState() {
    super.initState();
  }

  /// 인증이 필요한 API (지역 기반 관광지 조회)를 호출하는 함수
  Future<void> _fetchTourArea() async {
    try {
      final response = await _authService.fetchTourArea(
        baseYm: '202504', // 예시 데이터
        areaCd: '11', // 예시 데이터
        signguCd: '11260', // 예시 데이터
      );
      setState(() {
        _tourAreaResult =
            "조회 성공: ${response.data.toString().substring(0, 100)}..."; // 너무 길면 잘라냄
      });
    } catch (e) {
      setState(() {
        _tourAreaResult = "조회 실패: $e";
      });
      print('지역 기반 관광지 조회 실패: $e');
    }
  }

  /// 로그아웃 처리 함수 (여기서 직접 처리)
  Future<void> _logout() async {
    try {
      await _kakaoLoginService.logout(); // 카카오 및 앱 로그아웃
      if (mounted) {
        RouteManager.navigateToLogin(); // 로그아웃 성공 시 로그인 화면으로 이동
      }
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      // 사용자에게 오류 알림 등 추가 처리 가능
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("얼마GO"), // 앱 이름 변경
        actions: [
          // 메뉴 버튼 (로그아웃 포함)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(
                context, _kakaoLoginService), // _kakaoLoginService 전달
            tooltip: '메뉴',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 지도 영역 (KakaoMapScreen)
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
                        final amount = int.tryParse(amountController.text) ?? 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultMapScreen(amount: amount),
                          ),
                        );
                      },
                      child: const Text("🗺 추가 지도 보기"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchTourArea, // 인증 필요한 API 호출
                      child: const Text('인증 필요한 API 호출 (지역 관광지 조회)'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _tourAreaResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    // 홈 화면에서는 로그아웃 버튼을 직접 앱바 actions에 추가하는 것이 더 직관적일 수 있습니다.
                    // 또는 메뉴 안에 넣는 방식을 유지하려면 menu_utils.dart에서 처리해야 합니다.
                    // 이전 제안에서는 앱바에 로그아웃 아이콘을 넣었습니다.
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text('로그아웃'),
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
