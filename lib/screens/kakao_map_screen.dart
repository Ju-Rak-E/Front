import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class KakaoMapScreen extends StatelessWidget {
  const KakaoMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kakao Map")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://map.kakao.com"),
        ),
      ),
    );
  }
}
