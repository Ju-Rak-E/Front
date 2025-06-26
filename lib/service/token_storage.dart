import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰을 안전하게 저장하고 관리하는 클래스
///
/// flutter_secure_storage를 사용하여 iOS의 Keychain과 Android의 EncryptedSharedPreferences에
/// 토큰을 암호화하여 저장합니다.
class TokenStorage {
  // flutter_secure_storage 인스턴스 생성
  static const _storage = FlutterSecureStorage();

  // 저장소에서 사용할 키 값들
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// 액세스 토큰과 리프레시 토큰을 저장
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    print("✅ access token 저장됨: $accessToken");
    print("✅ refresh token 저장됨: $refreshToken");
  }

  /// 저장된 액세스 토큰을 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 저장된 리프레시 토큰을 가져오기
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 저장된 토큰 모두 삭제 (로그아웃용)
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    print("🧹 모든 토큰 삭제 완료");
  }

  /// 현재 저장된 토큰들을 출력하는 디버깅용 함수
  static Future<void> debugPrintStoredTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    print('🧪 현재 저장된 access token: $accessToken');
    print('🧪 현재 저장된 refresh token: $refreshToken');
  }
}
