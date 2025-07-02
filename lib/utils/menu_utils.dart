// lib/utils/menu_utils.dart

import 'package:flutter/material.dart';
import '../screens/profile_screen.dart'; // ProfileScreen 임포트
import '../screens/about_screen.dart'; // AboutScreen 임포트
import '../service/kakao_login_service.dart'; // KakaoLoginService 임포트
import '../utils/route_manager.dart'; // RouteManager 임포트

/// 앱의 메뉴를 BottomSheet로 표시하는 유틸리티 함수
///
/// [context] 현재 빌드 컨텍스트
/// [kakaoLoginService] KakaoLoginService 인스턴스 (로그인 상태 확인용)
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
                Navigator.pop(context); // BottomSheet 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('소개'),
              onTap: () {
                Navigator.pop(context); // BottomSheet 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('메인'),
              onTap: () {
                Navigator.pop(context); // BottomSheet 닫기
                RouteManager.navigateToHome(); // 홈으로 이동
              },
            ),
          ],
        ),
      );
    },
  );
}
