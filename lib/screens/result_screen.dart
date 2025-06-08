import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import '../constants/theme.dart';

class ResultScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int budget;
  final String placeName;
  final String address;
  final int price;

  const ResultScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.budget,
    required this.placeName,
    required this.address,
    required this.price,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late NaverMapController _mapController;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _addMarker();
  }

  void _addMarker() {
    _markers.add(
      Marker(
        markerId: 'place',
        position: LatLng(widget.latitude, widget.longitude),
        icon: NOverlayImage.fromAssetImage('assets/marker.png'),
        caption: NOverlayCaption(
          text: widget.placeName,
          color: Colors.white,
          haloColor: AppTheme.primaryColor,
          textSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 장소'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 공유 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 지도
          Expanded(
            flex: 2,
            child: NaverMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController.moveCamera(
                  CameraUpdate.withParams(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 15,
                  ),
                );
              },
              markers: _markers,
            ),
          ),
          
          // 장소 정보
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.address,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '예상 비용: ₩${widget.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('다시 뽑기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult(Map<String, String> place) {
    final text = '''
🎯 얼마Go 추천 맛집!

📍 ${place['name']}
⭐ 평점: ${place['rating']}
💰 가격: ${place['price']}
📍 거리: ${place['distance']}

${place['reason']}

#얼마Go #맛집추천
    ''';
    
    Share.share(text);
  }
}
