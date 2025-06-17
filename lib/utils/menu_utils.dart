// lib/utils/menu_utils.dart

import 'package:flutter/material.dart';
import '../screens/profile_screen.dart'; // ProfileScreen 임포트 (가정)
import '../screens/about_screen.dart'; // AboutScreen 임포트 (가정)
import '../service/kakao_login_service.dart'; // KakaoLoginService 임포트
import '../utils/route_manager.dart'; // RouteManager 임포트

/// 앱의 메뉴를 BottomSheet로 표시하는 유틸리티 함수
///
/// [context] 현재 빌드 컨텍스트
/// [kakaoLoginService] KakaoLoginService 인스턴스 (로그아웃 처리를 위해 필요)
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
                      builder: (context) => const ProfileScreen()),
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
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),

            //RouteManager를 사용하여 홈으로 이동하도록 수정
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('메인'),
              onTap: () {
                Navigator.pop(context); // BottomSheet 닫기
                RouteManager.navigateToHome(); // RouteManager 사용
              },
            ),
            // 로그인 상태에 따라 로그아웃 버튼 표시
            FutureBuilder<bool>(
              future: kakaoLoginService.checkLoginStatus(), // 비동기적으로 로그인 상태 확인
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // 로딩 중에는 아무것도 표시하지 않음
                }
                final bool isLoggedIn = snapshot.data ?? false; // 로그인 상태 가져오기

                if (isLoggedIn) {
                  return ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃'),
                    onTap: () async {
                      Navigator.pop(context); // BottomSheet 닫기
                      await kakaoLoginService.logout();
                      // 로그아웃 후 로그인 화면으로 이동
                      RouteManager.navigateToLogin(); // RouteManager 사용
                    },
                  );
                } else {
                  return const SizedBox.shrink(); // 로그아웃 상태면 로그아웃 버튼 숨김
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
