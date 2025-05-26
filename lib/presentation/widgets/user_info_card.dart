import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

/// 用户信息卡片
class UserInfoCard extends StatelessWidget {
  final UserEntity user;
  
  const UserInfoCard({
    super.key,
    required this.user,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
                  child: user.avatar.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname.isNotEmpty ? user.nickname : '未知用户',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UID: ${user.uid}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.isVip)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.star,
              label: '等级',
              value: 'Lv.${user.level}',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.monetization_on,
              label: '硬币',
              value: '${user.coins}',
              color: Colors.amber,
            ),
            if (user.signature.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.format_quote,
                label: '签名',
                value: user.signature,
                color: Colors.blue,
              ),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person,
              label: '性别',
              value: _getGenderText(user.gender),
              color: Colors.purple,
            ),
            if (user.birthday.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.cake,
                label: '生日',
                value: user.birthday,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  String _getGenderText(int gender) {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '保密';
    }
  }
} 