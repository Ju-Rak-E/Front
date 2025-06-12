import 'package:flutter/material.dart';
import '../utils/menu_utils.dart';
import '../widgets/kakao_login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final KakaoLoginService kakaoLoginService = KakaoLoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(context, kakaoLoginService),
          ),
        ],
      ),
      body: const Center(
        child: Text('마이페이지 내용이 들어갈 자리입니다.'),
      ),
    );
  }
} 