import 'package:geolocator/geolocator.dart';

/// 현재 기기의 위치 정보를 가져오는 유틸리티 함수
/// 성공 시 Position 객체를 반환하고, 실패 시 null 또는 fallback 좌표 반환 가능
Future<Position?> getCurrentLocation() async {
  // 1. 위치 서비스가 켜져 있는지 확인
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('❌ 위치 서비스가 꺼져 있습니다.');
    return null;
  }

  // 2. 위치 권한 요청
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      print('❌ 위치 권한 거부됨');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('❌ 위치 권한이 영구적으로 거부되었습니다.');
    return null;
  }

  // 3. 현재 위치 가져오기
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
    print('✅ 현재 위치: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    print('❌ 위치 가져오기 실패: $e');

    // 4. 실패 시 마지막으로 기록된 위치 사용
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      print('📌 마지막 위치 사용: ${lastKnown.latitude}, ${lastKnown.longitude}');
      return lastKnown;
    }

    return null;
  }
}
