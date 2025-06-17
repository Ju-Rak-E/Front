// lib/utils/location_utils.dart

import 'package:geolocator/geolocator.dart';

/// 현재 기기의 위치 정보를 가져오는 유틸리티 함수
///
/// 위치 서비스 활성화 여부 확인 및 권한 요청을 처리합니다.
/// 성공 시 Position 객체를 반환하고, 실패 시 null을 반환합니다.
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. 위치 서비스 활성화 여부 확인
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    // 사용자에게 위치 서비스 활성화를 유도하는 UI (예: 스낵바, 다이얼로그)를 추가할 수 있습니다.
    return null;
  }

  // 2. 위치 권한 상태 확인 및 요청
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print(
        'Location permissions are permanently denied, we cannot request permissions.');
    // 사용자에게 앱 설정으로 이동하여 권한을 변경하도록 안내하는 UI를 추가할 수 있습니다.
    return null;
  }

  // 3. 현재 위치 가져오기
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    return position;
  } catch (e) {
    print('Error getting location: $e');
    return null;
  }
}
