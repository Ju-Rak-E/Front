import 'package:flutter/material.dart';
import '../constants/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서비스 소개'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서비스 로고
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 서비스 소개
            const Text(
              '얼마Go는 무엇인가요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '얼마Go는 사용자의 예산에 맞는 주변 장소를 추천해주는 서비스입니다. '
              '지금 당장 어디 갈지 고민하지 마세요. 얼마Go가 당신의 선택을 도와드립니다.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // 사용 방법
            const Text(
              '사용 방법',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              icon: Icons.location_on,
              title: '1. 위치 확인',
              description: '현재 위치를 확인하여 주변 장소를 찾습니다.',
            ),
            _buildStepCard(
              icon: Icons.attach_money,
              title: '2. 예산 입력',
              description: '원하는 예산을 입력합니다.',
            ),
            _buildStepCard(
              icon: Icons.search,
              title: '3. 장소 추천',
              description: '입력한 예산에 맞는 장소를 추천해드립니다.',
            ),
            const SizedBox(height: 32),

            // 향후 업데이트
            const Text(
              '향후 업데이트',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUpdateCard(
              title: '카테고리 필터',
              description: '음식점, 카페, 공원 등 원하는 장소 유형을 선택할 수 있습니다.',
            ),
            _buildUpdateCard(
              title: '리뷰 시스템',
              description: '방문한 장소에 대한 리뷰를 남기고 다른 사용자의 리뷰를 확인할 수 있습니다.',
            ),
            _buildUpdateCard(
              title: '즐겨찾기',
              description: '마음에 드는 장소를 저장하고 나중에 다시 찾아볼 수 있습니다.',
            ),
            const SizedBox(height: 32),

            // 개발자 정보
            const Text(
              '개발자 정보',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDeveloperCard(
              name: '팀 얼마Go',
              role: '개발팀',
              description: '더 나은 서비스를 위해 노력하고 있습니다.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
