import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({super.key});

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late final WebViewController _controller;
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _getCurrentLocation();
  }

  // WebView 초기화 함수
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('웹뷰 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            print('웹뷰 로딩 완료: $url');
            setState(() {
              _isLoading = false;
            });
            if (_currentPosition != null) {
              _loadKakaoMap(_currentPosition!);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  // 현재 위치를 얻는 함수
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화되어 있습니다.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _loadKakaoMap(position);
      }
    } catch (e) {
      print('위치 정보 가져오기 실패: $e');
    }
  }

  // KakaoMap에 현재 위치를 전달하는 함수
  void _loadKakaoMap(Position position) {
    final mapUrl = Uri.encodeFull(
      'https://map.kakao.com/link/map/현재위치,'
      '${position.latitude},'
      '${position.longitude}'
    );
    
    _controller.loadRequest(Uri.parse(mapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}