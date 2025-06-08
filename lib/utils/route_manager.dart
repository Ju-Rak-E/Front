import 'package:flutter/material.dart';

class RouteManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 현재 컨텍스트를 가져오는 메서드
  static BuildContext? get currentContext => navigatorKey.currentState?.context;

  // 이름으로 라우트 이동
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // 이름으로 라우트 교체
  static Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // 모든 라우트를 제거하고 새 라우트로 이동
  static Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // 뒤로 가기
  static void goBack() {
    return navigatorKey.currentState!.pop();
  }

  // 결과 페이지로 이동 (예산 정보 전달)
  static Future<dynamic> navigateToResult(String budget) {
    return navigateTo('/result', arguments: {'budget': budget});
  }

  // 홈으로 돌아가기 (모든 라우트 제거)
  static Future<dynamic> navigateToHome() {
    return navigateToAndRemoveUntil('/');
  }

  // 로그인 페이지로 이동
  static Future<dynamic> navigateToLogin() {
    return navigateTo('/login');
  }

  // 소개 페이지로 이동
  static Future<dynamic> navigateToAbout() {
    return navigateTo('/about');
  }

  // 기록 페이지로 이동
  static Future<dynamic> navigateToHistory() {
    return navigateTo('/history');
  }

  // 프로��/설정 페이지로 이동
  static Future<dynamic> navigateToProfile() {
    return navigateTo('/profile');
  }
}
