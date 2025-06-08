import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../utils/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToMarketing = false;
  bool _isLoading = false;

  /// 카카오 로그인을 수행하는 메서드
  Future<void> _handleKakaoLogin() async {
    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 약관에 동의해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 카카오톡으로 로그인 시도
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 설치되어 있지 않은 경우 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }
      
      // 로그인 성공 시 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      print('카카오 로그인 성공: ${user.kakaoAccount?.profile?.nickname}');
      
      // TODO: 백엔드 서버에 카카오 액세스 토큰 전송하여 JWT 토큰 발급받기
      
      // 로그인 성공 후 홈으로 이동
      RouteManager.navigateToHome();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 성공!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (error) {
      print('카카오 로그인 실패: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Google 로그인 (추후 구현)
  Future<void> _handleGoogleLogin() async {
    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 약관에 동의해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showLoginProgress('Google');
  }

  /// Apple 로그인 (추후 구현)
  Future<void> _handleAppleLogin() async {
    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 약관에 동의해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showLoginProgress('Apple');
  }

  void _showLoginProgress(String provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
            SizedBox(height: 16),
            Text('$provider 로그인 중...'),
          ],
        ),
      ),
    );

    // 2초 후 로그인 성공으로 시뮬레이션 (실제로는 해당 로그인 로직 구현)
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 다이얼로그 닫기
      RouteManager.navigateToHome();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$provider 로그인 성공!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                  ),
                  SizedBox(height: 16),
                  Text('카카오 로그인 중...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  
                  // 로고 및 환영 메시지
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4A90E2).withOpacity(0.3),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          '얼마Go에 오신 것을 환영합니다!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          '로그인하고 더 많은 기능을 이용해보세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 50),
                  
                  // 약관 동의
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '약관 동의',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        _buildAgreementItem(
                          '서비스 이용약관 동의 (필수)',
                          _agreeToTerms,
                          (value) => setState(() => _agreeToTerms = value!),
                          isRequired: true,
                        ),
                        
                        _buildAgreementItem(
                          '개인정보 처리방침 동의 (필수)',
                          _agreeToPrivacy,
                          (value) => setState(() => _agreeToPrivacy = value!),
                          isRequired: true,
                        ),
                        
                        _buildAgreementItem(
                          '마케팅 정보 수신 동의 (선택)',
                          _agreeToMarketing,
                          (value) => setState(() => _agreeToMarketing = value!),
                          isRequired: false,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // 소셜 로그인 버튼들
                  Text(
                    '소셜 계정으로 로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // 카카오 로그인 (기존 로직 사용)
                  _buildSocialLoginButton(
                    '카카오로 로그인',
                    Color(0xFFFEE500),
                    Color(0xFF3C1E1E),
                    Icons.chat_bubble,
                    () => _handleKakaoLogin(),
                    enabled: _agreeToTerms && _agreeToPrivacy,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Google 로그인
                  _buildSocialLoginButton(
                    'Google로 로그인',
                    Colors.white,
                    Color(0xFF4285F4),
                    Icons.g_mobiledata,
                    () => _handleGoogleLogin(),
                    enabled: _agreeToTerms && _agreeToPrivacy,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Apple 로그인 (iOS에서만)
                  _buildSocialLoginButton(
                    'Apple로 로그인',
                    Colors.black,
                    Colors.white,
                    Icons.apple,
                    () => _handleAppleLogin(),
                    enabled: _agreeToTerms && _agreeToPrivacy,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // 게스트로 계속하기
                  TextButton(
                    onPressed: () {
                      RouteManager.navigateToHome();
                    },
                    child: Text(
                      '로그인 없이 계속하기',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // 개인정보 처리방침 링크
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          '로그인 시 ',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showTermsDialog(),
                          child: Text(
                            '이용약관',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          ' 및 ',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showPrivacyDialog(),
                          child: Text(
                            '개인정보처리방침',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          '에 동의한 것으로 간주됩니다.',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAgreementItem(
    String text,
    bool value,
    ValueChanged<bool?> onChanged, {
    required bool isRequired,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF4A90E2),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                fontWeight: isRequired ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (isRequired)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFE74C3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '필수',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButton(
    String text,
    Color backgroundColor,
    Color textColor,
    IconData icon,
    VoidCallback onPressed, {
    required bool enabled,
  }) {
    return Container(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? backgroundColor : Colors.grey[300],
          foregroundColor: enabled ? textColor : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: backgroundColor == Colors.white 
                  ? Colors.grey[300]! 
                  : Colors.transparent,
            ),
          ),
          elevation: enabled ? 2 : 0,
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이용약관'),
        content: SingleChildScrollView(
          child: Text(
            '얼마Go 서비스 이용약관\n\n'
            '제1조 (목적)\n'
            '본 약관은 얼마Go가 제공하는 서비스의 이용조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.\n\n'
            '제2조 (정의)\n'
            '1. "서비스"란 얼마Go가 제공하는 맛집 추천 서비스를 의미합니다.\n'
            '2. "회원"이란 본 약관에 동의하고 서비스를 이용하는 자를 의미합니다.\n\n'
            '제3조 (약관의 효력 및 변경)\n'
            '본 약관은 서비스 화면에 게시하거나 기타의 방법으로 회원에게 공지함으로써 효력을 발생합니다.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('개인정보처리방침'),
        content: SingleChildScrollView(
          child: Text(
            '얼마Go 개인정보처리방침\n\n'
            '1. 개인정보의 처리목적\n'
            '얼마Go는 다음의 목적을 위하여 개인정보를 처리합니다.\n'
            '- 서비스 제공 및 맞춤형 추천\n'
            '- 회원 관리 및 본인확인\n'
            '- 고객 상담 및 불만처리\n\n'
            '2. 개인정보의 처리 및 보유기간\n'
            '개인정보는 수집·이용에 관한 동의일로부터 개인정보의 수집·이용목적을 달성할 때까지 보유·이용됩니다.\n\n'
            '3. 개인정보의 제3자 제공\n'
            '얼마Go는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
