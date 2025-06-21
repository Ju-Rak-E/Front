import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/location_utils.dart'; // getCurrentLocation 함수

class NaverMapScreen extends StatefulWidget {
  const NaverMapScreen({super.key});

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  late NaverMapController _mapController;
  NLatLng _currentLatLng = const NLatLng(37.5665, 126.9780); // 기본 위치: 서울
  NMarker? _myLocationMarker;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initLocationAndMarker());
  }

  Future<void> _initLocationAndMarker() async {
    final position = await getCurrentLocation();

    if (position != null) {
      _currentLatLng = NLatLng(position.latitude, position.longitude);
      _myLocationMarker = NMarker(
        id: 'my_location',
        position: _currentLatLng,
        caption: const NOverlayCaption(text: '📍 내 위치'),
      );
      setState(() {}); // 위치 설정 후 UI 갱신
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _currentLatLng,
                zoom: 14,
              ),
              locationButtonEnable: true,
              scaleBarEnable: true,
              // zoomControlEnable: true, // ❌ 1.3.1에는 없음
            ),
            onMapReady: (controller) {
              _mapController = controller;
              setState(() {
                _isMapReady = true;
              });

              if (_myLocationMarker != null) {
                _mapController.addOverlay(_myLocationMarker!); // ✅ 내 위치 마커 추가
              }
            },
          ),

          // ✅ 로딩 인디케이터
          if (!_isMapReady) const Center(child: CircularProgressIndicator()),

          // ✅ 확대/축소 버튼
          if (_isMapReady)
            Positioned(
              bottom: 60,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoom_in",
                    mini: true,
                    onPressed: () {
                      _mapController.updateCamera(NCameraUpdate.zoomIn());
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    mini: true,
                    onPressed: () {
                      _mapController.updateCamera(NCameraUpdate.zoomOut());
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
