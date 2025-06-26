import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaxiService {
  static final String baseUrl = dotenv.env['BACKEND_BASE_URL']!;

  static Future<double?> fetchRadius({
    required double latitude,
    required double longitude,
    required int fare,
  }) async {
    final url = Uri.parse('$baseUrl/api/taxi/estimate-radius');

    final token = await TokenStorage.getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'fare': fare,
        'mode': 'MULTIPLE', // 이전에 언급된 백엔드 요청에서 mode가 빠져있었습니다. 필요하다면 추가해주세요.
      }),
    );

    print('📦 TaxiService - 백엔드 응답 상태 코드: ${response.statusCode}');
    print('📦 TaxiService - 백엔드 응답 바디: ${response.body}'); // 응답 바디 출력하여 확인

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 'radiusInMeters' 대신 'radius'로 변경해야 합니다.
      if (data.containsKey('radius')) {
        // 'radius' 키가 존재하는지 확인하는 것이 좋습니다.
        return data['radius']?.toDouble();
      } else {
        print('❌ 응답 데이터에 "radius" 키가 없습니다.');
        return null;
      }
    } else {
      print('❌ 요금 계산 API 요청 실패: ${response.statusCode}');
      print('❌ 실패 응답 바디: ${response.body}');
      return null;
    }
  }
}
