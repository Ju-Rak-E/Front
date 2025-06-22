import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverMapService {
  static final Dio _dio = Dio();
  static final String _baseUrl =
      'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc';

  static Future<Map<String, String>?> getRegionCodes({
    required double latitude,
    required double longitude,
  }) async {
    final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    final clientSecret = dotenv.env['NAVER_MAP_SECRET_KEY'];

    if (clientId == null || clientSecret == null) {
      print('❌ .env에서 네이버 키를 불러오지 못했습니다.');
      return null; // 키를 불러오지 못한 경우 null을 반환합니다.
    } else {
      print('✅ clientId: $clientId');
      print('✅ clientSecret: $clientSecret');
      // 여기서 return 하지 마세요. API 호출을 진행해야 합니다.
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
        validateStatus: (status) => true, // ✅ 모든 상태 코드를 허용
      ),
    );
    print('📦 응답 상태 코드: ${response.statusCode}');
    print('📦 응답 바디: ${response.data}');

    if (response.statusCode == 200) {
      final results = response.data['results'];
      if (results != null && results is List && results.isNotEmpty) {
        final codeId = results[0]['code']['id']; // 예: "1111010100"
        final areaCd = codeId.substring(0, 2); // 서울특별시 → 11
        final sigunguCd = codeId.substring(0, 5); // 종로구 → 11110
        return {
          'codeId': codeId,
          'areaCd': areaCd,
          'sigunguCd': sigunguCd,
        };
      } else {
        print('❗ 결과 없음: ${response.data}');
      }
    } else {
      print('❌ 네이버 Reverse Geocoding 실패: ${response.statusCode}');
      // 가능한 경우 응답에서 오류 메시지를 출력하는 것이 도움이 됩니다.
      if (response.data != null &&
          response.data is Map &&
          response.data.containsKey('errorMessage')) {
        print('네이버에서 받은 오류 메시지: ${response.data['errorMessage']}');
      }
    }

    return null;
  }
}
