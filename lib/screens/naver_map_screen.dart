import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class NaverMapScreen extends StatefulWidget {
  const NaverMapScreen({super.key});

  static _NaverMapScreenState? _mapState;

  static void updateRadiusExternally({
    required double lat,
    required double lng,
    required double radius,
  }) {
    _mapState?._updateRadiusExternally(lat, lng, radius);
  }

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  late NaverMapController _mapController;
  NLatLng _currentLatLng = const NLatLng(37.5665, 126.9780);
  NMarker? _myLocationMarker;
  NCircleOverlay? _radiusCircle;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    NaverMapScreen._mapState = this;
    Future.microtask(() => _initializeLocation());
  }

  Future<void> _initializeLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    _currentLatLng = NLatLng(position.latitude, position.longitude);

    _myLocationMarker = NMarker(
      id: 'my_location',
      position: _currentLatLng,
      caption: const NOverlayCaption(text: '📍 내 위치'),
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

  void _updateRadiusExternally(double lat, double lng, double radius) {
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
    if (_myLocationMarker != null) {
      _mapController.addOverlay(_myLocationMarker!);
    }
    _mapController.addOverlay(circle);

    const earthRadius = 6371000.0;
    final angularDistance = radius / earthRadius;

    final minLat = lat - (angularDistance * 180 / pi);
    final maxLat = lat + (angularDistance * 180 / pi);
    final minLng = lng - (angularDistance * 180 / pi) / cos(lat * pi / 180);
    final maxLng = lng + (angularDistance * 180 / pi) / cos(lat * pi / 180);

    final bounds = NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );

    final cameraUpdate = NCameraUpdate.fitBounds(
      bounds,
      padding: const EdgeInsets.all(50), // 수정된 부분
    );
    _mapController.updateCamera(cameraUpdate);

    setState(() {
      _radiusCircle = circle;
    });
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
