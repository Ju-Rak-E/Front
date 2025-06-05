import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'screens/home_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env"); // .env 파일 로딩
    print("✅ ENV LOADED 네이버클라이언트 ID: ${dotenv.env['NAVER_CLIENT_ID']}");

    await NaverMapSdk.instance.initialize(
      clientId: dotenv.env['NAVER_CLIENT_ID']!,
    );

    print("✅ ENV LOADED 백엔드 베이스URL: ${dotenv.env['BACKEND_BASE_URL']}");

    // 카카오 SDK 초기화
    KakaoSdk.init(
      nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
      customScheme: dotenv.env['REDIRECT_URI']!,
    );
    print("카카오 SDK 초기화 체크: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}");
    print("카카오 커스텀 스킴킴: ${dotenv.env['REDIRECT_URI']}");
  } catch (e) {
    print("❌ Failed to load .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naver Map + KakaoT (.env)',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}
