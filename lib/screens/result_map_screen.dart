
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../utils/kakao_launcher.dart';

class ResultMapScreen extends StatefulWidget {
  final int amount;
  const ResultMapScreen({super.key, required this.amount});

  @override
  State<ResultMapScreen> createState() => _ResultMapScreenState();
}

class _ResultMapScreenState extends State<ResultMapScreen> {
  final NLatLng markerPosition = const NLatLng(37.5444, 127.0371);

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 160,
        child: Column(
          children: [
            const ListTile(
              title: Text("서울숲"),
              subtitle: Text("여기로 카카오T 택시 호출하시겠어요?"),
            ),
            ElevatedButton(
              onPressed: () {
                launchKakaoT(markerPosition.latitude, markerPosition.longitude, "서울숲");
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
    return Scaffold(
      appBar: AppBar(title: const Text("지도 보기")),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: markerPosition, zoom: 13),
        ),
        onMapReady: (controller) async {
          final marker = NMarker(id: "dest", position: markerPosition);
          marker.setOnTapListener((overlay) => _showBottomSheet(context));
          await controller.addOverlay(marker);
        },
      ),
    );
  }
}
