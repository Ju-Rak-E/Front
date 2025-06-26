import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint용
import '../utils/api_client.dart';

class TourService {
  /// 반경 내 관광지 정보 조회
  static Future<void> fetchTourSpotsWithinRadius({
    required double centerLat,
    required double centerLng,
    required double radiusInMeters,
  }) async {
    final String baseYm = '202506';
    final apiClient = ApiClient();

    try {
      final response = await apiClient.authenticatedRequest(
        '/api/tour/area',
        method: 'GET',
        data: {
          'baseYm': baseYm,
          'latitude': centerLat,
          'longitude': centerLng,
          'radius': radiusInMeters,
        },
        extra: {'requiresAuth': true},
      );

      debugPrint('✅ 관광지 응답 전체 보기:\n${response.data.toString()}',
          wrapWidth: 1024);
    } on DioException catch (e) {
      print('❌ DioException 발생!');
      print('👉 타입: ${e.type}');
      print('👉 메시지: ${e.message}');
      print('👉 URL: ${e.requestOptions.uri}');
      print('👉 응답: ${e.response}');
    } catch (e) {
      print('❌ 기타 예외: $e');
    }
  }
}
