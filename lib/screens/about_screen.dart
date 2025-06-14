import 'package:flutter/material.dart';
import '../utils/menu_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/kakao_login.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final KakaoLoginService kakaoLoginService = KakaoLoginService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소개'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(context, kakaoLoginService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 로고 및 제목
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
                      Icons.location_on,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '얼마Go',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '예산 맞춤 맛집 추천 서비스',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // 서비스 소개
            _buildSection(
              '🎯 서비스 소개',
              '택시비 입력 후 떠나는 랜덤 여행, 오늘의 행선지는 어디?'
              '한 번의 요금 입력으로 당신만의 관광지, 맛집, 핫플이 쏟아진다!'
              '운빨+추천이 결합된 신개념 여행 제안 서비스!',
            ),
            
            SizedBox(height: 30),
            
            // 사용 방법
            _buildSection(
              '📱 사용 방법',
              '',
            ),
            
            _buildStepCard(1, '위치 권한 허용', '정확한 주변 맛집 추천을 위해 위치 권한을 허용해주세요.'),
            _buildStepCard(2, '예산 입력', '택시비로 지불할 금액을 입력해주세요.'),
            _buildStepCard(3, '얼마Go 버튼 클릭', '버튼을 누르면 해당 금액으로 갈 수 있는 거리 내에 \'핫플\'을 찾아드려요.'),
            _buildStepCard(4, '장소 클릭', '추천장소와 관련높은 장소들도 추천해드립니다!'),
            
            SizedBox(height: 30),
            
            // 주요 기능
            _buildSection(
              '✨ 주요 기능',
              '',
            ),
            
            _buildFeatureCard(Icons.location_on, '위치 기반 추천', '현재 위치 주변의 플레이스만 추천해드려요.'),
            _buildFeatureCard(Icons.attach_money, '예산 맞춤', '입력한 예산 범위 내의 플레이스만 선별해드려요.'),
            _buildFeatureCard(Icons.star, '평점 기반', '리뷰와 평점이 좋은 검증된 플레이스만 추천해요.'),
            _buildFeatureCard(Icons.history, '기록 관리', '방문한 플레이스 기록을 저장하고 관리할 수 있어요.'),
            
            SizedBox(height: 30),
            
            // 향후 업데이트
            _buildSection(
              '🚀 향후 업데이트',
              '더 나은 서비스를 위해 지속적으로 업데이트하고 있습니다!',
            ),
            
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUpdateItem('🍽️ 선호 플레이스 카테고리 필터링'),
                  _buildUpdateItem('👥 친구와 함께 갈 플레이스 고르기'),
                  _buildUpdateItem('📊 개인 맞춤 추천 알고리즘'),
                  _buildUpdateItem('🎁 쿠폰 및 할인 정보 제공'),
                  _buildUpdateItem('📝 리뷰 및 평점 시스템'),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // 개발자 정보
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2).withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    '개발자 정보',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactButton(
                        Icons.email,
                        '이메일',
                        () => _launchEmail(),
                      ),
                      _buildContactButton(
                        Icons.code,
                        'GitHub',
                        () => _launchGitHub(),
                      ),
                      _buildContactButton(
                        Icons.web,
                        '웹사이트',
                        () => _launchWebsite(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // 버전 정보
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        if (content.isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF34495E),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepCard(int step, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Color(0xFF4A90E2),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF34495E),
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF4A90E2), size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@rmago.com',
      query: 'subject=얼마Go 문의사항',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchGitHub() async {
    final Uri githubUri = Uri.parse('https://github.com/rmago');
    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri);
    }
  }

  void _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://eolmago.com');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    }
  }
} 