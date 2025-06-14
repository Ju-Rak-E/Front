import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/kakao_login.dart';

void showAppMenu(BuildContext context, KakaoLoginService kakaoLoginService) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('마이페이지'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('소개'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('메인'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            if (kakaoLoginService.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: () async {
                  Navigator.pop(context);
                  await kakaoLoginService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
          ],
        ),
      );
    },
  );
} 