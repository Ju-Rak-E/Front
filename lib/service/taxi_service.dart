import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
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
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['radiusInMeters']?.toDouble();
    } else {
      print('요금 계산 API 요청 실패: ${response.statusCode}');
      return null;
    }
  }
}