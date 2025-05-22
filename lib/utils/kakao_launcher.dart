
import 'package:url_launcher/url_launcher.dart';

Future<void> launchKakaoT(double lat, double lng, String name) async {
  final url = Uri.parse(
      'kakaot://launch?tapp=taxi&dest_lat=\$lat&dest_lng=\$lng&dest_name=\$name');

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    const marketUrl = 'https://play.google.com/store/apps/details?id=com.kakao.taxi';
    if (await canLaunchUrl(Uri.parse(marketUrl))) {
      await launchUrl(Uri.parse(marketUrl));
    } else {
      throw '카카오T를 실행할 수 없습니다.';
    }
  }
}
