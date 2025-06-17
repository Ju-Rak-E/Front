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

  Position? _userLocation; // 사용자의 위치 정보를 저장할 변수
  bool _isLocationLoading = false; // 위치 정보 로딩 중 여부
  String _locationStatusText = "위치 정보를 가져오는 중..."; // 위치 상태를 표시하는 텍스트

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission(); // 화면 진입 시 위치 권한 확인 및 요청
    _checkAutoLogin(); // 자동 로그인 상태 확인
  }

  /// 앱 시작 시 저장된 JWT 토큰을 확인하여 자동 로그인 처리
  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await _kakaoLoginService.checkLoginStatus();
    if (isLoggedIn) {
      // JWT가 있다면 바로 홈 화면으로 이동 시도
      if (mounted) {
        RouteManager.navigateToHome();
      }
    }
  }

  /// 위치 권한 확인 및 현재 위치를 가져오는 함수
  Future<void> _checkAndRequestLocationPermission() async {
    setState(() {
      _isLocationLoading = true; // 로딩 시작
      _locationStatusText = "위치 정보를 가져오는 중...";
    });

    final position = await getCurrentLocation(); // `location_utils.dart`의 함수 호출
    if (position != null) {
      setState(() {
        _userLocation = position; // 위치 정보 저장
        _locationStatusText =
            "위치 권한 획득됨: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
      print('위치 권한 획득 및 좌표: ${position.latitude}, ${position.longitude}');
    } else {
      setState(() {
        _userLocation = null; // 위치 정보 가져오기 실패
        _locationStatusText = "위치 권한 거부 또는 가져오기 실패";
      });
      print('위치 권한 거부 또는 위치 정보 가져오기 실패');
    }
    setState(() {
      _isLocationLoading = false; // 로딩 종료
    });
  }

  /// 카카오 로그인 프로세스를 시작하는 함수
  Future<void> _loginWithKakao() async {
    // 위치 정보가 없거나 로딩 중이면 로그인 진행하지 않음
    if (_userLocation == null && !_isLocationLoading) {
      print('위치 정보가 없어 카카오 로그인을 진행할 수 없습니다. 다시 권한 요청을 시도합니다.');
      await _checkAndRequestLocationPermission(); // 다시 권한 요청 시도
      if (_userLocation == null) {
        // 여전히 위치 정보가 없다면 사용자에게 알림 후 로그인 중단
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한이 필요합니다. 앱 설정을 확인해주세요.')),
          );
        }
        return;
      }
    } else if (_isLocationLoading) {
      print('위치 정보를 가져오는 중입니다. 잠시 후 다시 시도해주세요.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 정보를 가져오는 중입니다. 잠시 후 다시 시도해주세요.')),
        );
      }
      return;
    }

    try {
      // KakaoLoginService를 통해 카카오 인증 수행
      await _kakaoLoginService.loginWithKakao(
        onSuccess: (kakaoAccessToken) async {
          // 카카오 인증 성공 후, 백엔드 로그인 API 호출 시 위치 정보 전달
          await _authService.kakaoLogin(kakaoAccessToken,
              position: _userLocation);

          // 백엔드 로그인 성공 후 홈 화면으로 이동
          if (mounted) {
            RouteManager.navigateToHome();
          }
        },
      );
    } catch (e) {
      print('카카오 로그인 또는 백엔드 통신 실패: $e');
      if (mounted) {
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
