import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../utils/menu_utils.dart';
import '../service/kakao_login_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final KakaoLoginService kakaoLoginService = KakaoLoginService();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserInfo();
  }

  Future<User?> _fetchUserInfo() async {
    try {
      return await UserApi.instance.me();
    } catch (e) {
      print('❌ 사용자 정보 불러오기 실패: $e');
      return null;
    }
  }

  Future<void> _logout() async {
    await kakaoLoginService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login'); // 로그인 화면으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => showAppMenu(context, kakaoLoginService),
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          final nickname = user.kakaoAccount?.profile?.nickname ?? '닉네임 없음';
          final email = user.kakaoAccount?.email ?? '이메일 없음';
          final profileImage = user.kakaoAccount?.profile?.profileImageUrl;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (profileImage != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                const SizedBox(height: 20),
                Text(
                  nickname,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('내 정보 수정'),
                  onTap: () {
                    // TODO: 내 정보 수정 화면으로 이동
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('추천 기록 보기'),
                  onTap: () {
                    // TODO: 기록 화면으로 이동
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('로그아웃'),
                  onTap: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
