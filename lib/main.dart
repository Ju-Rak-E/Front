import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env");
    print("✅ ENV LOADED: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}");

    print('ENV KEY: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}');

    //카카오 SDK 초기화(네이티브 앱 키는 .env에서 불러옴)
    KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);
    print("카카오 SDK 초기화 체크");
  } catch (e) {
    print("❌ Failed to load .env: \$e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Map + KakaoT',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}
