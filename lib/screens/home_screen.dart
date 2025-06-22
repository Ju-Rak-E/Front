import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/auth_service.dart';
import '../service/kakao_login_service.dart';
import '../utils/route_manager.dart';
import '../utils/menu_utils.dart';
import 'naver_map_screen.dart';
import '../utils/location_utils.dart';
import '../service/taxi_service.dart';
import '../service/naver_map_service.dart'; // ✅ 네이버 reverse geocoding

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
    if (position != null && mounted) {
      setState(() {
        _myLat = position.latitude;
        _myLng = position.longitude;
      });
    }
  }

  Future<void> _searchPlaces() async {
    final amount = int.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar("유효한 금액을 입력하세요.");
      return;
    }

    if (_myLat == null || _myLng == null) {
      _showSnackBar("현재 위치를 확인할 수 없습니다.");
      return;
    }

    try {
      // ✅ 1. 지역코드 조회 (실패해도 계속 진행)
      try {
        final region = await NaverMapService.getRegionCodes(
          latitude: _myLat!,
          longitude: _myLng!,
        );

        if (region != null) {
          final areaCd = region['areaCd'];
          final sigunguCd = region['sigunguCd'];
          print('🎯 관광공사 지역코드: areaCd = $areaCd / sigunguCd = $sigunguCd');
          // 👉 관광공사 API 요청 여기에 넣어도 OK
        } else {
          print('❌ 지역코드 결과가 null입니다.');
        }
      } catch (e) {
        print('❌ 지역코드 조회 중 오류: $e');
      }

      // ✅ 2. 반경 계산 및 지도 표시
      final radius = await TaxiService.fetchRadius(
        latitude: _myLat!,
        longitude: _myLng!,
        fare: amount,
      );

      if (radius != null) {
        setState(() {
          _tourAreaResult = "💡 약 ${radius.toStringAsFixed(1)}m 반경까지 이동 가능";
          _places = [];
        });

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
      print('❌ _searchPlaces 전체 예외: $e');
      setState(() {
        _tourAreaResult = "❌ 조회 실패: $e";
        _places = [];
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
              onSubmitted: (_) {
                FocusScope.of(context).unfocus(); // 키보드만 내리기
              },
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
            onPressed: () async {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 300));
              _searchPlaces();
            },
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
              SizedBox(height: mapHeight, child: const NaverMapScreen()),
              SizedBox(height: inputHeight, child: _buildInputSection()),
            ],
          );
        },
      ),
    );
  }
}
