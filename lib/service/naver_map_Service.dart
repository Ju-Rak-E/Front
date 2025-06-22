import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverMapService {
  static final Dio _dio = Dio();
  static final String _baseUrl =
      'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc';

  /// 단일 좌표로 지역코드 가져오기
  static Future<Map<String, String>?> getRegionCodes({
    required double latitude,
    required double longitude,
  }) async {
    final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    final clientSecret = dotenv.env['NAVER_MAP_SECRET_KEY'];

    if (clientId == null || clientSecret == null) {
      print('❌ .env에서 네이버 키를 불러오지 못했습니다.');
      return null;
    }

    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'coords': '$longitude,$latitude',
        'output': 'json',
        'orders': 'legalcode',
      },
      options: Options(
        headers: {
          'X-NCP-APIGW-API-KEY-ID': clientId,
          'X-NCP-APIGW-API-KEY': clientSecret,
        },
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      final results = response.data['results'];
      if (results != null && results is List && results.isNotEmpty) {
        final codeId = results[0]['code']['id'];
        final areaCd = codeId.substring(0, 2);
        final sigunguCd = codeId.substring(0, 5);
        return {
          'codeId': codeId,
          'areaCd': areaCd,
          'sigunguCd': sigunguCd,
        };
      }
    } else {
      print('❌ API 실패: ${response.statusCode}, 응답 내용: ${response.data}');
    }

    return null;
  }

  /// 반경 내 여러 좌표를 샘플링하여 고유한 시군구 코드 모으기
  static Future<Set<String>> findRegionCodesWithinRadius({
    required double centerLat,
    required double centerLng,
    required double radiusInMeters,
  }) async {
    const int sampleCount = 120; // 샘플링 수 충분히 증가
    const double earthRadius = 6371000.0;
    final Set<String> regionCodes = {};

    final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    final clientSecret = dotenv.env['NAVER_MAP_SECRET_KEY'];

    if (clientId == null || clientSecret == null) {
      print('❌ .env에서 네이버 키를 불러오지 못했습니다.');
      return regionCodes;
    }

    print('🔍 샘플링 시작 - 반경 ${radiusInMeters}m 내 총 ${sampleCount}개 좌표');

    for (int i = 0; i < sampleCount; i++) {
      final angle = 2 * pi * i / sampleCount;
      final dx = radiusInMeters * cos(angle);
      final dy = radiusInMeters * sin(angle);

      final sampledLat = centerLat + (dy / earthRadius) * (180 / pi);
      final sampledLng = centerLng +
          (dx / (earthRadius * cos(centerLat * pi / 180))) * (180 / pi);

      print('🧪 샘플 좌표 $i: ($sampledLat, $sampledLng)');

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'coords': '$sampledLng,$sampledLat',
          'output': 'json',
          'orders': 'admcode',
        },
        options: Options(
          headers: {
            'X-NCP-APIGW-API-KEY-ID': clientId,
            'X-NCP-APIGW-API-KEY': clientSecret,
          },
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        final results = response.data['results'];
        if (results != null && results is List && results.isNotEmpty) {
          for (var item in results) {
            final codeId = item['code']['id'];
            final sigunguCd = codeId.substring(0, 5);
            if (!regionCodes.contains(sigunguCd)) {
              print('🎯 새 시군구 발견: $sigunguCd');
            }
            regionCodes.add(sigunguCd);
          }
        }
      } else {
        print('❌ 샘플링 실패 [$i]: ${response.statusCode}');
      }
    }

    print('📦 최종 탐색된 시군구 코드 수: ${regionCodes.length}');
    return regionCodes;
  }
}
