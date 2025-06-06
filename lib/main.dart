import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 사용자 SDK
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'; // 카카오 공통 SDK
import 'screens/home_screen.dart'; // 홈 화면
import 'service/auth_service.dart'; // 백엔드와의 통신을 담당하는 AuthService
import 'screens/login_screen.dart';
import 'utils/route_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Flutter 초기화 (비동기 코드 처리 전에 반드시 호출)

  try {
    // .env 파일에서 환경 변수 로드
    await dotenv.load(fileName: "assets/.env");
    print(
        "✅ ENV LOADED: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}"); // KAKAO_NATIVE_APP_KEY 출력
    print(
        "✅ ENV LOADED 백엔드 베이스URL: ${dotenv.env['BACKEND_BASE_URL']}"); // 백엔드 URL 출력

    // 카카오 SDK 초기화
    KakaoSdk.init(
      nativeAppKey:
          dotenv.env['KAKAO_NATIVE_APP_KEY']!, // .env에서 KAKAO_NATIVE_APP_KEY 로드
      customScheme: dotenv.env['REDIRECT_URI']!, // 카카오 로그인 후 리디렉션 URI
    );
    print(
        "카카오 SDK 초기화 체크: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}"); // 카카오 SDK 초기화 확인
    print("카카오 커스텀 스킴킴: ${dotenv.env['REDIRECT_URI']}"); // 카카오 커스텀 스킴 확인
  } catch (e) {
    print("❌ Failed to load .env: $e"); // .env 파일 로드 실패 시 출력
  }

  runApp(const MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Map + KakaoT',  // 앱 제목
      theme: ThemeData(primarySwatch: Colors.green),  // 앱의 기본 색상 설정
      navigatorKey: RouteManager.navigatorKey,
      routes: {
        '/': (context) => const HomeScreen(), // 홈 화면을 설정
        '/login': (context) => const LoginScreen(),
      },
      initialRoute: '/',
    );
  }
}
