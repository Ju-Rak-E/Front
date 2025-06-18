import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({super.key});

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late WebViewController _controller;
  Position? _currentPosition;
  bool _mounted = true;  // mounted 상태를 추적하기 위한 플래그 추가

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mounted = false;  // dispose 시 플래그를 false로 설정
    super.dispose();
  }

  // WebView 초기화 함수
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('웹뷰 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            print('웹뷰 로딩 완료: $url');
            if (_currentPosition != null) {
              _loadKakaoMap(_currentPosition!);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}');
          },
        ),
      );
    _controller.loadRequest(Uri.parse('https://map.kakao.com'));
  }

  // 현재 위치를 얻는 함수
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    if (!_mounted) return;  // 이미 dispose된 경우 실행하지 않음

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있습니다.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('위치 권한이 거부되었습니다.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!_mounted) return;  // 비동기 작업 완료 후 mounted 상태 확인

    setState(() {
      _currentPosition = position;
    });

    if (_mounted) {  // _loadKakaoMap 호출 전에도 mounted 상태 확인
      _loadKakaoMap(position);
    }
  }

  // KakaoMap에 현재 위치를 전달하는 함수
  void _loadKakaoMap(Position position) {
    final latitude = position.latitude;
    final longitude = position.longitude;

    // 카카오맵 JavaScript API에 마커 및 바운더리 표시를 위한 스크립트 작성
    final script = """
      var marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng($latitude, $longitude)
      });
      marker.setMap(map);

      var circle = new kakao.maps.Circle({
        center: new kakao.maps.LatLng($latitude, $longitude), // 중심 좌표
        radius: 100, // 바운더리 반경 (단위: 미터)
        strokeWeight: 2,
        strokeColor: '#75B8FA',
        strokeOpacity: 1,
        fillColor: '#A2C9FF',
        fillOpacity: 0.3
      });
      circle.setMap(map);
    """;

    _controller.runJavaScript(script); // JavaScript 코드 실행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}