import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/auth_service.dart';
import '../service/kakao_login_service.dart';
import '../utils/route_manager.dart';
import '../utils/menu_utils.dart';
import 'naver_map_screen.dart';
import '../utils/location_utils.dart'; // 위치 가져오기 유틸
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

  /// ✅ 금액을 넘겨 백엔드에서 반경 계산 (장소는 아직 없음)
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
          _tourAreaResult = "💡 약 "+radius.toStringAsFixed(1)+"m 반경까지 이동 가능";
          _places = []; // 장소 리스트는 추후 확장
        });
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

  /// ✅ 카카오T 앱 실행 (내 위치 ➡ 목적지)
  Future<void> _launchKakaoT(double destLat, double destLng) async {
    if (_myLat == null || _myLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치 정보를 불러오는 중입니다.')),
      );
      return;
    }

    final url =
        "kakaomap://route?sp=$_myLat,$_myLng&ep=$destLat,$destLng&by=CAR";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오T 실행에 실패했습니다.')),
      );
    }
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
      body: Column(
        children: [
          const Flexible(flex: 8, child: NaverMapScreen()),
          Flexible(
            flex: 4,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "금액 입력 (예: 10000)",
                              border: OutlineInputBorder(),
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
                    const SizedBox(height: 10),
                    Text(
                      _tourAreaResult,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    if (_places.isNotEmpty)
                      ..._places.map((place) {
                        return Card(
                          child: ListTile(
                            title: Text(place['name']),
                            subtitle: Text(
                                "위도: ${place['lat']}, 경도: ${place['lng']}"),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  _launchKakaoT(place['lat'], place['lng']),
                              child: const Text("카카오T로 이동"),
                            ),
                          ),
                        );
                      }),
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
