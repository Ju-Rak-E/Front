import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/routes.dart';
import '../utils/token_storage.dart';
import '../utils/route_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // 방문 기록 섹션
            _buildSectionTitle('방문 기록'),
            const SizedBox(height: 16),
            _buildVisitHistory(),
            const SizedBox(height: 24),

            // 설정 섹션
            _buildSectionTitle('설정'),
            const SizedBox(height: 16),
            _buildSettingsList(),
            const SizedBox(height: 24),

            // 로그아웃 버튼
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await TokenStorage.deleteToken();
                  if (context.mounted) {
                    RouteManager.navigateToLogin();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 20),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '사용자',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '일반 회원',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVisitHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVisitHistoryItem(
            name: '맛있는 식당',
            date: '2024-03-15',
            price: '25,000원',
          ),
          _buildDivider(),
          _buildVisitHistoryItem(
            name: '편안한 카페',
            date: '2024-03-10',
            price: '15,000원',
          ),
          _buildDivider(),
          _buildVisitHistoryItem(
            name: '즐거운 공원',
            date: '2024-03-05',
            price: '0원',
          ),
        ],
      ),
    );
  }

  Widget _buildVisitHistoryItem({
    required String name,
    required String date,
    required String price,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.notifications,
            title: '알림 설정',
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.lock,
            title: '개인정보 보호',
            onTap: () {
              // TODO: 개인정보 보호 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.help,
            title: '도움말',
            onTap: () {
              // TODO: 도움말 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
