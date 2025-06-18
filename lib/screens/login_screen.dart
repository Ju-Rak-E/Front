import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Position 타입 사용
import '../utils/location_utils.dart'; // 위치 유틸리티 임포트
import '../service/auth_service.dart'; // AuthService 임포트
import '../service/kakao_login_service.dart'; // KakaoLoginService 임포트
import '../utils/route_manager.dart'; // RouteManager 임포트

/// 앱의 로그인 화면
/// 카카오 로그인 및 위치 권한 요청을 처리합니다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  final AuthService _authService = AuthService();
  bool _mounted = true; // 위젯 마운트 상태 추적

  Position? _userLocation;
  bool _isLocationLoading = false;
  String _locationStatusText = "위치 정보를 가져오는 중...";

  @override
  void initState() {
    super.initState();
    _initializeLoginPage();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _initializeLoginPage() async {
    await _checkAutoLogin();
    if (_mounted) {
      await _checkAndRequestLocationPermission();
    }
  }

  Future<void> _checkAutoLogin() async {
    try {
      final isLoggedIn = await _kakaoLoginService.checkLoginStatus();
      if (isLoggedIn && _mounted) {
        RouteManager.navigateToHome();
      }
    } catch (e) {
      print('자동 로그인 확인 중 오류 발생: $e');
    }
  }

  Future<void> _checkAndRequestLocationPermission() async {
    if (!_mounted) return;

    _safeSetState(() {
      _isLocationLoading = true;
      _locationStatusText = "위치 정보를 가져오는 중...";
    });

    try {
      final position = await getCurrentLocation();
      if (!_mounted) return;

      _safeSetState(() {
        _userLocation = position;
        _locationStatusText = position != null
            ? "위치 권한 획득됨: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}"
            : "위치 권한 거부 또는 가져오기 실패";
        _isLocationLoading = false;
      });
    } catch (e) {
      if (!_mounted) return;
      
      _safeSetState(() {
        _userLocation = null;
        _locationStatusText = "위치 정보 가져오기 실패: ${e.toString()}";
        _isLocationLoading = false;
      });
    }
  }

  // 안전한 setState 호출을 위한 헬퍼 메서드
  void _safeSetState(VoidCallback fn) {
    if (_mounted && mounted) {
      setState(fn);
    }
  }

  Future<void> _loginWithKakao() async {
    if (!_mounted) return;

    if (_userLocation == null && !_isLocationLoading) {
      print('위치 정보 없음. 권한 재요청...');
      await _checkAndRequestLocationPermission();
      if (!_mounted) return;
      
      if (_userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다. 앱 설정을 확인해주세요.')),
        );
        return;
      }
    }

    if (_isLocationLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 정보를 가져오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    try {
      await _kakaoLoginService.loginWithKakao(
        onSuccess: (kakaoAccessToken) async {
          await _authService.kakaoLogin(kakaoAccessToken, position: _userLocation);
          if (_mounted && mounted) {
            RouteManager.navigateToHome();
          }
        },
      );
    } catch (e) {
      print('로그인 실패: $e');
      if (_mounted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // ✅ 배경 이미지 + ShaderMask 오버레이
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.1),
                ],
              ).createShader(bounds),
              blendMode: BlendMode.srcATop,
              child: Image.asset(
                'assets/images/splashImage.png',
                fit: BoxFit.cover,
                width: screenWidth,
                height: screenHeight,
              ),
            ),

            // ✅ 내용물
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ 상단 텍스트
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0),
                    child: Column(
                      children: [
                        Text(
                          '계획짤 시간에\n벌써 도착!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'BMDOHYEON',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '얼마GO',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 100,
                            fontFamily: 'BMDOHYEON',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),

                  // ✅ 위치 정보 상태 표시
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      _locationStatusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _userLocation != null
                            ? Colors.greenAccent
                            : Colors.amberAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ 카카오 로그인 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // 위치 로딩 중이거나 카카오 로그인 서비스가 로딩 중이면 버튼 비활성화
                        onPressed:
                            (_isLocationLoading || _kakaoLoginService.isLoading)
                                ? null
                                : _loginWithKakao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9E000),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _kakaoLoginService
                                .isLoading // 카카오 로그인 서비스 로딩 중이면 로딩 인디케이터 표시
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text(
                                '카카오로 시작하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}