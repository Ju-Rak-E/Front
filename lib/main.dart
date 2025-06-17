import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 사용자 SDK
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'; // 카카오 공통 SDK
import 'screens/home_screen.dart'; // 홈 화면
import 'screens/login_screen.dart'; // 로그인 화면
import 'utils/route_manager.dart'; // RouteManager
import 'utils/api_client.dart'; // ApiClient (초기화를 위해)

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Flutter 초기화 (비동기 코드 처리 전에 반드시 호출)

  try {
    // .env 파일에서 환경 변수 로드
    await dotenv.load(fileName: ".env");
    print(
        "✅ ENV LOADED: KAKAO_NATIVE_APP_KEY = ${dotenv.env['KAKAO_NATIVE_APP_KEY']}");
    print("✅ ENV LOADED: BACKEND_BASE_URL = ${dotenv.env['BACKEND_BASE_URL']}");
    print("✅ ENV LOADED: REDIRECT_URI = ${dotenv.env['REDIRECT_URI']}");

    // ApiClient 초기화 (Base URL 및 인터셉터 설정)
    // ApiClient() 호출 시 내부 생성자에서 Dio 인스턴스 생성 및 인터셉터 등록
    ApiClient(); // 싱글톤 인스턴스 초기화

    // 카카오 SDK 초기화
    // .env 파일의 KAKAO_NATIVE_APP_KEY와 REDIRECT_URI 사용
    KakaoSdk.init(
      nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
      customScheme: dotenv.env['REDIRECT_URI']!,
    );
    print("✅ 카카오 SDK 초기화 완료");
  } catch (e) {
    print("❌ 초기화 실패: $e");
    print("앱 구동에 필요한 환경 변수(.env) 또는 SDK 초기화에 문제가 있습니다.");
    // 앱이 정상적으로 동작하지 않을 수 있으므로, 사용자에게 알림을 주거나 앱을 종료하는 로직 추가 가능
    // 예를 들어, 치명적인 오류라면 다음 라인을 추가하여 앱을 종료할 수 있습니다.
    // exit(1);
  }

  runApp(const MyApp()); // 앱 실행
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rmago', // 앱 제목
      theme: ThemeData(primarySwatch: Colors.green), // 앱의 기본 색상 설정
      navigatorKey: RouteManager.navigatorKey, // RouteManager에 navigatorKey 설정
      routes: {
        '/': (context) => const HomeScreen(), // 홈 화면 라우트
        '/login': (context) => const LoginPage(), // 로그인 화면 라우트
      },
      initialRoute: '/login', // 앱 시작 시 초기 라우트를 로그인 화면으로 설정
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}
