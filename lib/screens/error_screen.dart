import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/routes.dart';
import '../utils/route_manager.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final String? errorCode;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.errorCode,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 에러 아이콘
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 32),

                // 에러 메시지
                Text(
                  errorMessage ?? '알 수 없는 오류가 발생했습니다',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 에러 코드 (있는 경우)
                if (errorCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '에러 코드: $errorCode',
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 도움말 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '문제 해결 방법',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHelpItem(
                        icon: Icons.refresh,
                        text: '앱을 다시 시작해보세요',
                      ),
                      _buildHelpItem(
                        icon: Icons.wifi,
                        text: '인터넷 연결을 확인해주세요',
                      ),
                      _buildHelpItem(
                        icon: Icons.update,
                        text: '앱을 최신 버전으로 업데이트해주세요',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 액션 버튼들
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    RouteManager.navigateToHome();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('홈으로 돌아가기'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 고객 지원 연락처로 연결
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('고객 지원 문의'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
