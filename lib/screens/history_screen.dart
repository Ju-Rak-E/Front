import 'package:flutter/material.dart';
import '../constants/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = '전체';
  final List<String> _filters = ['전체', '음식점', '카페', '공원', '기타'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 칩
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // 방문 기록 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // 임시 데이터
              itemBuilder: (context, index) {
                return _buildHistoryItem(
                  name: '방문 장소 ${index + 1}',
                  date: '2024-03-${15 - index}',
                  price: '${(index + 1) * 5000}원',
                  category: _filters[index % _filters.length],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String name,
    required String date,
    required String price,
    required String category,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // 장소 정보
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 장소 아이콘
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
                // 장소 상세 정보
                Expanded(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 가격 정보
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // 구분선
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.1),
          ),
          // 액션 버튼
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.map,
                  label: '지도 보기',
                  onTap: () {
                    // TODO: 지도 보기 기능 구현
                  },
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: '공유하기',
                  onTap: () {
                    // TODO: 공유하기 기능 구현
                  },
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: '삭제',
                  onTap: () {
                    // TODO: 삭제 기능 구현
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '필터',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filters.map((filter) {
                  final isSelected = filter == _selectedFilter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = '전체';
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('필터 초기화'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
