import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/auth_service.dart';
import '../service/kakao_login_service.dart';
import '../utils/route_manager.dart';
import '../utils/menu_utils.dart';
import 'naver_map_screen.dart';
import '../utils/location_utils.dart';
import '../service/taxi_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final AuthService _authService = AuthService();
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();

  List<Map<String, dynamic>> _places = [];
  String _tourAreaResult = "";
  double? _myLat;
  double? _myLng;

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    final position = await getCurrentLocation();
    if (position != null) {
      setState(() {
        _myLat = position.latitude;
        _myLng = position.longitude;
      });
    }
  }

  Future<void> _searchPlaces() async {
    final amount = int.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("유효한 금액을 입력하세요.")),
      );
      return;
    }

    if (_myLat == null || _myLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("현재 위치를 확인할 수 없습니다.")),
      );
      return;
    }

    try {
      final double? radius = await TaxiService.fetchRadius(
        latitude: _myLat!,
        longitude: _myLng!,
        fare: amount,
      );

      if (radius != null) {
        setState(() {
          _tourAreaResult = "💡 약 ${radius.toStringAsFixed(1)}m 반경까지 이동 가능";
          _places = [];
        });

        // NaverMapScreen에 반경 표시 요청
        NaverMapScreen.updateRadiusExternally(
          lat: _myLat!,
          lng: _myLng!,
          radius: radius,
        );
      } else {
        setState(() {
          _tourAreaResult = "❌ 반경 계산 실패";
          _places = [];
        });
      }
    } catch (e) {
      setState(() {
        _tourAreaResult = "❌ 조회 실패: $e";
        _places = [];
      });
    }
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "금액 입력 (예: 10000)",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _searchPlaces,
            child: const Text("검색"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("얼마GO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(context, _kakaoLoginService),
            tooltip: '메뉴',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = constraints.maxHeight * 0.85;
          final inputHeight = constraints.maxHeight * 0.15;

          return Column(
            children: [
              SizedBox(
                height: mapHeight,
                child: const NaverMapScreen(),
              ),
              SizedBox(
                height: inputHeight,
                child: _buildInputSection(),
              ),
            ],
          );
        },
      ),
    );
  }
}
