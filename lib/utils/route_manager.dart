import 'package:flutter/material.dart';

/// 앱의 라우팅을 관리하는 클래스
class RouteManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 로그인 화면으로 이동하는 메서드
  ///
  /// [clearStack] true인 경우 이전 화면 스택을 모두 제거하고 로그인 화면만 남깁니다.
  static Future<void> navigateToLogin({bool clearStack = true}) async {
    if (clearStack) {
      // 모든 이전 화면을 제거하고 로그인 화면으로 이동
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login', // 로그인 화면의 라우트 이름
        (route) => false, // 모든 이전 라우트 제거
      );
    } else {
      // 현재 화면 위에 로그인 화면을 쌓음
      await navigatorKey.currentState?.pushNamed('/login');
    }
  }

  //**홈화면을 이동하는 메서드
  //이전 화면 스택을 모두 제거후 홈 화면만 남김 */
  static Future<void> navigateToHome() async {
    //모든 이전 화면을 제거하고 홈 화면으로 이동
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }
}
