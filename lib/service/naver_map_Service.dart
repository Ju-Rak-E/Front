import 'dart:convert';
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
}
