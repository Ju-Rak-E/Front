import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰을 안전하게 저장하고 관리하는 클래스
/// 
/// flutter_secure_storage를 사용하여 iOS의 Keychain과 Android의 EncryptedSharedPreferences에
/// 토큰을 암호화하여 저장합니다.
class TokenStorage {
  // flutter_secure_storage 인스턴스 생성
  // iOS에서는 Keychain, Android에서는 EncryptedSharedPreferences를 사용
  static const _storage = FlutterSecureStorage();
  
  // 저장소에서 사용할 키 값들
  static const _accessTokenKey = 'access_token';  // 액세스 토큰을 저장할 키
  static const _refreshTokenKey = 'refresh_token';  // 리프레시 토큰을 저장할 키

  /// 액세스 토큰과 리프레시 토큰을 저장하는 메서드
  /// 
  /// [accessToken] 백엔드에서 발급받은 JWT 액세스 토큰
  /// [refreshToken] 백엔드에서 발급받은 JWT 리프레시 토큰
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // 액세스 토큰을 안전한 저장소에 저장
    await _storage.write(key: _accessTokenKey, value: accessToken);
    // 리프레시 토큰을 안전한 저장소에 저장
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// 저장된 액세스 토큰을 가져오는 메서드
  /// 
  /// Returns: 저장된 액세스 토큰 또는 토큰이 없는 경우 null
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 저장된 리프레시 토큰을 가져오는 메서드
  /// 
  /// Returns: 저장된 리프레시 토큰 또는 토큰이 없는 경우 null
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 저장된 모든 토큰을 삭제하는 메서드
  /// 
  /// 로그아웃 시 사용됩니다.
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
} 