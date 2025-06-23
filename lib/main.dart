import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/route_manager.dart';
import 'utils/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ .env 환경 변수 로드
    await dotenv.load(fileName: ".env");

    print("✅ ENV LOADED");
    print("KAKAO_NATIVE_APP_KEY: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}");
    print("REDIRECT_URI: ${dotenv.env['REDIRECT_URI']}");
    print("BACKEND_BASE_URL: ${dotenv.env['BACKEND_BASE_URL']}");
    print("NAVER_MAP_SECRET_KEY: ${dotenv.env['NAVER_MAP_SECRET_KEY']}");
    print("NAVER_MAP_CLIENT_ID: ${dotenv.env['NAVER_MAP_CLIENT_ID']}");

    // ✅ NaverMap 초기화
    await FlutterNaverMap().init(
      clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
      onAuthFailed: (ex) {
        print('❌ 네이버맵 인증 오류: $ex');
      },
    );

    print('✅ FlutterNaverMap initialized');

    // ✅ Kakao SDK 초기화
    KakaoSdk.init(
      nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
      customScheme: dotenv.env['REDIRECT_URI']!,
    );
    print("✅ Kakao SDK initialized");

    print("✅ NaverMap SDK initialized");

    // ✅ API 클라이언트 초기화
    ApiClient();
  } catch (e) {
    print("❌ 초기화 실패: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rmago',
      theme: ThemeData(primarySwatch: Colors.green),
      navigatorKey: RouteManager.navigatorKey,
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
      },
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
    );
  }
}
