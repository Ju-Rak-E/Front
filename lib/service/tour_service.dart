import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 추가 필요
import '../service/naver_map_service.dart'; // 네이버 맵 reverse geo

class TourService {
  static Future<void> fetchTourSpotsWithinRadius({
    required double centerLat,
    required double centerLng,
    required double radiusInMeters,
  }) async {
    final sigunguCodes = await NaverMapService.findRegionCodesWithinRadius(
      centerLat: centerLat,
      centerLng: centerLng,
      radiusInMeters: radiusInMeters,
    );

    if (sigunguCodes.isEmpty) {
      print('❌ 탐색된 지역 코드 없음');
      return;
    }

    final String baseYm = '202506';
    final String backendUrl = dotenv.env['BACKEND_BASE_URL']!;

    final response = await http.post(
      Uri.parse('$backendUrl/api/tour/multiple-areas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'baseYm': baseYm,
        'sigunguCdList': sigunguCodes.toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ 관광지 응답: $data');

      // 👇 마커 찍는 로직과 연결하거나 반환
    } else {
      print('❌ 관광지 요청 실패: ${response.statusCode}');
    }
  }
}
