import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MarkerService {
  final Dio dio;

  MarkerService(this.dio);

  /// 네이버 지도 마커를 위한 관광지 데이터 요청 및 마커 생성
  Future<List<NMarker>> fetchMarkers({
    required double lat,
    required double lng,
    required double radius,
    required String category,
  }) async {
    print('📡 [MarkerService] 마커 불러오기 시작');

    try {
      final response = await dio.get(
        '${dotenv.env['BACKEND_BASE_URL']}/api/tour/area',
        data: {
          'latitude': lat,
          'longitude': lng,
          'radius': radius,
          'category': category,
        },
        options: Options(extra: {'requiresAuth': true}),
      );

      print('📥 응답 상태 코드: ${response.statusCode}');
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      // JSON 구조에 따라 관광지 리스트 파싱
      final List<dynamic> items = data is List
          ? data
          : data['response']?['body']?['items']?['item'] ?? [];

      if (items.isEmpty) {
        print('⚠️ 반환된 관광지 데이터 없음');
        return [];
      }

      final List<NMarker> markers = [];

      for (final item in items) {
        final double? latitude = double.tryParse(item['lat']?.toString() ?? '');
        final double? longitude =
            double.tryParse(item['lng']?.toString() ?? '');
        final String title = item['name']?.toString() ?? '이름 없음';

        if (latitude == null || longitude == null) {
          print('⚠️ 좌표 정보 누락: $item');
          continue;
        }

        final marker = NMarker(
          id: 'marker_${title}_${latitude}_${longitude}',
          position: NLatLng(latitude, longitude),
          caption: NOverlayCaption(text: title),
        );

        markers.add(marker);
        print('✅ 마커 생성: $title ($latitude, $longitude)');
      }

      print('🎉 마커 ${markers.length}개 생성 완료');
      return markers;
    } catch (e, stack) {
      print('❌ 마커 생성 실패: $e');
      return [];
    }
  }
}
