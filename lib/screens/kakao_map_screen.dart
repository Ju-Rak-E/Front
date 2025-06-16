import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapScreen extends StatefulWidget {
  const KakaoMapScreen({super.key});

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("🟡 WebView started loading: $url");
          },
          onPageFinished: (url) {
            print("✅ WebView finished loading: $url");
          },
          onNavigationRequest: (request) {
            print("➡️ WebView navigation request: ${request.url}");
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print("❌ WebView resource error:");
            print("   ⤷ Code: ${error.errorCode}");
            print("   ⤷ Description: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse('https://map.kakao.com'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
