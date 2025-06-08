import 'package:flutter/material.dart';
import '../constants/theme.dart';

class LoadingAnimation extends StatefulWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingAnimation({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로딩 아이콘
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 로딩 메시지
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // 로딩 인디케이터
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor.withOpacity(0.5),
              ),
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );

    if (widget.isFullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: loadingWidget,
      );
    }

    return loadingWidget;
  }
}

// 사용 예시:
// 1. 전체 화면 로딩
// LoadingAnimation(
//   message: '주변 장소를 찾는 중...',
//   isFullScreen: true,
// )

// 2. 부분 화면 로딩
// LoadingAnimation(
//   message: '로딩 중...',
//   isFullScreen: false,
// )
