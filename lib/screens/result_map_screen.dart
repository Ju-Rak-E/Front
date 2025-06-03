
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/kakao_launcher.dart';

class ResultMapScreen extends StatefulWidget {
  final int amount;
  const ResultMapScreen({super.key, required this.amount});

  @override
  State<ResultMapScreen> createState() => _ResultMapScreenState();
}

 //TODO pangvelop : 현재 위치 연동 추가

class _ResultMapScreenState extends State<ResultMapScreen> {
  late InAppWebViewController webViewController;
  final double lat = 37.5444;
  final double lng = 127.0371;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) =>
          SizedBox(
            height: 160,
            child: Column(
              children: [
                const ListTile(
                  title: Text("서울숲"),
                  subtitle: Text("여기로 카카오T 택시 호출하시겠어요?"),
                ),
                ElevatedButton(
                  onPressed: () {
                    launchKakaoT(lat, lng, "서울숲");
                  },
                  child: const Text("카카오T 호출하기"),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapUrl = Uri.encodeFull(
        "https://map.kakao.com/link/map/서울숲,37.5444,127.0371"
    );

    return Scaffold(
      appBar: AppBar(title: const Text("지도 보기")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(mapUrl), // ✅ 안전한 카카오맵 링크 사용
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStop: (controller, url) {
          print("✅ 지도 로딩 완료: $url");
        },
        onLoadError: (controller, url, code, message) {
          print("❌ 로딩 실패 [$code]: $message");
        },
        onLongPressHitTestResult: (controller, result) {
          _showBottomSheet(context);
        },
      ),
    );
  }
}
