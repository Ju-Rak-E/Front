import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_rmago_app_env_fixed/service/token_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../service/marker_service.dart';
import '../dio/dio_instance.dart';

class NaverMapScreen extends StatefulWidget {
  const NaverMapScreen({super.key});

  static _NaverMapScreenState? _mapState;

  static void updateRadiusExternally({
    required double lat,
    required double lng,
    required double radius,
    String? category,
  }) {
    _mapState?._updateRadiusExternally(lat, lng, radius, category!);
  }

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  late NaverMapController _mapController;
  NLatLng _currentLatLng = const NLatLng(37.5665, 126.9780); // 기본값: 서울 시청
  NMarker? _myLocationMarker;
  NCircleOverlay? _radiusCircle;
  bool _isMapReady = false;

  final MarkerService _markerService = MarkerService(dio);
  final List<NMarker> _dynamicMarkers = [];

  @override
  void initState() {
    super.initState();
    NaverMapScreen._mapState = this;

    Future.microtask(() async {
      setupDio();
      await _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    _currentLatLng = NLatLng(position.latitude, position.longitude);

    _myLocationMarker = NMarker(
      id: 'my_location',
      position: _currentLatLng,
    );

    if (_isMapReady) {
      _moveCameraToCurrent();
      _mapController.addOverlay(_myLocationMarker!);
    }

    setState(() {});
  }

  void _moveCameraToCurrent() {
    _mapController.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: _currentLatLng,
        zoom: 14,
      ),
    );
  }

  void _updateRadiusExternally(
      double lat, double lng, double radius, String category) async {
    _currentLatLng = NLatLng(lat, lng);

    final circle = NCircleOverlay(
      id: 'estimated_radius',
      center: _currentLatLng,
      radius: radius,
      color: Colors.green.withOpacity(0.3),
      outlineColor: Colors.green,
      outlineWidth: 2,
    );

    _mapController.clearOverlays();
    _dynamicMarkers.clear();

    if (_myLocationMarker != null) {
      _mapController.addOverlay(_myLocationMarker!);
    }
    _mapController.addOverlay(circle);

    // 카메라 영역 계산
    const earthRadius = 6371000.0;
    final angularDistance = radius / earthRadius;
    final minLat = lat - (angularDistance * 180 / math.pi);
    final maxLat = lat + (angularDistance * 180 / math.pi);
    final minLng =
        lng - (angularDistance * 180 / math.pi) / math.cos(lat * math.pi / 180);
    final maxLng =
        lng + (angularDistance * 180 / math.pi) / math.cos(lat * math.pi / 180);

    final bounds = NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );

    _mapController.updateCamera(
      NCameraUpdate.fitBounds(bounds, padding: const EdgeInsets.all(50)),
    );

    setState(() {
      _radiusCircle = circle;
    });

    try {
      final markers = await _markerService.fetchMarkers(
        lat: lat,
        lng: lng,
        radius: radius / 1000,
        category: category,
      );

      for (final marker in markers) {
        final pos = marker.position;
        if (pos.latitude == 0 || pos.longitude == 0) {
          print("⚠️ 유효하지 않은 마커 건너뜀");
          continue;
        }

        // 📍 마커 클릭 시 말풍선 띄우기
        marker.setOnTapListener((overlay) {
          final title = marker.caption?.text ?? '이름 없음';
          _showMarkerInfoBottomSheet(title, pos);
        });

        _mapController.addOverlay(marker);
        _dynamicMarkers.add(marker);
      }

      print("✅ ${_dynamicMarkers.length}개 마커 지도에 추가 완료");
    } catch (e, st) {
      print("❌ 마커 로딩 실패: $e");
      print("📛 StackTrace: $st");
    }
  }

  void _showMarkerInfoBottomSheet(String title, NLatLng position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final lat = position.latitude;
                      final lng = position.longitude;
                      print('🧭 코스 생성 클릭: $lat, $lng');

                      final url = Uri.parse('http://192.168.0.2:8080/api/laas/recommend');
                      final token = await TokenStorage.getAccessToken();

                      final response = await http.post(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token', // 토큰 필요 시 주석 해제
                        },
                        body: jsonEncode({
                          'title': title,
                          'lat': lat,
                          'lng': lng,
                        }),
                      );

                      if (response.statusCode == 200) {
                        final jsonData = json.decode(response.body);
                        final laasResult = jsonData['choices'][0]['message']['content'];
                        print("라스 결과: ${laasResult}");

                        // 🎯 모달로 결과 표시
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("추천 결과"),
                            content: SingleChildScrollView(
                              child: Text(laasResult),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("닫기"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("에러"),
                            content: Text("요청 실패: ${response.statusCode}"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("닫기"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: const Text("코스 생성"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      print(
                          '🚕 카카오T 클릭: ${position.latitude}, ${position.longitude}');
                    },
                    icon: const Icon(Icons.local_taxi),
                    label: const Text("카카오T"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: _currentLatLng,
              zoom: 14,
            ),
            locationButtonEnable: true,
            scaleBarEnable: true,
            consumeSymbolTapEvents: true,
          ),
          onMapReady: (controller) {
            _mapController = controller;
            _isMapReady = true;
            if (_myLocationMarker != null) {
              _mapController.addOverlay(_myLocationMarker!);
              _moveCameraToCurrent();
            }
            setState(() {});
          },
        ),
        if (_isMapReady)
          Positioned(
            bottom: 60,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  onPressed: () =>
                      _mapController.updateCamera(NCameraUpdate.zoomIn()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  onPressed: () =>
                      _mapController.updateCamera(NCameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
