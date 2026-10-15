import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/auth/auth_service.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                user?.name[0] ?? 'U',
                style: const TextStyle(fontSize: 40, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),

            // Profile Info
            _buildInfoTile(Icons.email, 'Email', user?.email ?? ''),
            _buildInfoTile(Icons.phone, 'Mobile', user?.mobile ?? ''),
            _buildInfoTile(Icons.badge, 'Role', user?.role.label ?? ''),

            const Spacer(),

            // Logout Button
            CustomButton(
              text: 'Logout',
              backgroundColor: Colors.red,
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}