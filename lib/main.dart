
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/env");
    print("✅ ENV LOADED: ${dotenv.env['NAVER_CLIENT_ID']}");
    await NaverMapSdk.instance.initialize(
      clientId: dotenv.env['NAVER_CLIENT_ID']!,
    );
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
      title: 'Naver Map + KakaoT (.env)',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}
