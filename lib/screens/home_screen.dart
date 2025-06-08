// 최초 작성자: 김광오
// 수정자 : 김병훈, 남인경
// 최초 작성일:
// 작성 이유: 카카오 로그인 버튼을 화면 상단에 배치하고 금액 입력 및 지도 보기 기능 구성
// 수정 내용: 새로운 UI 디자인 적용, 위치 권한 요청, 애니메이션 효과 추가

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'result_map_screen.dart';
import '../widgets/kakao_login.dart';
import '../widgets/healthCheckButton .dart'; // HealthCheckButton을 불러옴
import '../widgets/loading_animation.dart';
import '../utils/route_manager.dart';
import '../constants/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController amountController = TextEditingController();
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    setState(() {
      _locationPermissionGranted = permission != LocationPermission.denied;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationError = null;
      _isLoading = true;
    });

    try {
      // 위치 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition();
      print('현재 위치: ${position.latitude}, ${position.longitude}');
      
      // TODO: 위치 정보를 사용하여 장소 추천 요청

    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startRecommendation() {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예산을 입력해주세요')),
      );
      return;
    }

    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('얼마Go', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => RouteManager.navigateToAbout(),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => RouteManager.navigateToLogin(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 메인 컨텐츠
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 로고 또는 이미지
                const Icon(
                  Icons.location_on,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),
                
                // 예산 입력 필드
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '예산을 입력하세요',
                    prefixText: '₩ ',
                    hintText: '예: 10000',
                  ),
                ),
                const SizedBox(height: 24),
                
                // 얼마Go 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _startRecommendation,
                  child: const Text(
                    '얼마Go!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                
                // 위치 에러 메시지
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
              ],
            ),
          ),
          
          // 로딩 애니메이션
          if (_isLoading)
            const LoadingAnimation(),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF4A90E2), size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
