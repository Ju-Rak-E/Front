import 'package:flutter/material.dart';
import 'package:flutter_rmago_app_env_fixed/service/tour_service.dart';
import 'package:flutter_rmago_app_env_fixed/service/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/auth_service.dart';
import '../service/kakao_login_service.dart';
import '../utils/route_manager.dart';
import '../utils/menu_utils.dart';
import 'naver_map_screen.dart';
import '../utils/location_utils.dart';
import '../service/taxi_service.dart';
import '../service/naver_map_service.dart';

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

  final List<String> _categories = [
    '관광지',
    '문화시설',
    '행사',
    '여행',
    '레포츠',
    '숙박',
    '쇼핑',
    '음식점'
  ];
  String _selectedCategory = '관광지';

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
    TokenStorage.debugPrintStoredTokens();
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

  int getCurrentBaseFare() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 23 || hour < 2) return 6700;
    if (hour >= 2 && hour < 4) return 5800;
    if (hour >= 22 && hour < 23) return 5800;
    return 4800;
  }

  Future<void> _searchPlaces() async {
    final amount = int.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar("유효한 금액을 입력하세요.");
      return;
    }

    final baseFare = getCurrentBaseFare();
    if (amount < baseFare) {
      _showSnackBar("기본 요금 ${baseFare.toString()}원 이상 가능합니다!");
      return;
    }

    if (_myLat == null || _myLng == null) {
      _showSnackBar("현재 위치를 확인할 수 없습니다.");
      return;
    }

    try {
      // ✅ 지역코드 조회
      try {
        final region = await NaverMapService.getRegionCodes(
          latitude: _myLat!,
          longitude: _myLng!,
        );

        if (region != null) {
          final areaCd = region['areaCd'];
          final sigunguCd = region['sigunguCd'];
          print('🎯 관광공사 지역코드: areaCd = $areaCd / sigunguCd = $sigunguCd');
        } else {
          print('❌ 지역코드 결과가 null입니다.');
        }
      } catch (e) {
        print('❌ 지역코드 조회 중 오류: $e');
      }

      // ✅ 반경 계산 및 지도 표시
      final radius = await TaxiService.fetchRadius(
        latitude: _myLat!,
        longitude: _myLng!,
        fare: amount,
        category: _selectedCategory,
      );

      if (radius != null) {
        setState(() {
          _tourAreaResult = "💡 약 ${radius.toStringAsFixed(1)}m 반경까지 이동 가능";
          _places = [];
        });

        await TourService.fetchTourSpotsWithinRadius(
          centerLat: _myLat!,
          centerLng: _myLng!,
          radiusInMeters: radius,
        );

        NaverMapScreen.updateRadiusExternally(
          lat: _myLat!,
          lng: _myLng!,
          radius: radius,
          category: _selectedCategory,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                  await _searchPlaces();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("검색"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: Stack(
        children: [
          // 🗺 지도 배경
          const Positioned.fill(child: NaverMapScreen()),

          // 🧾 입력창 + 카테고리 버튼 (키보드가 보일 때 위로 띄움)
          Align(
            alignment: isKeyboardVisible
                ? Alignment.bottomCenter
                : Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isKeyboardVisible ? bottomInset : 20,
                left: 10,
                right: 10,
                top: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildInputSection(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
