import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/auth/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      user?.name[0] ?? 'U',
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role.label ?? 'Customer',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Options
            _buildSettingsTile(Icons.person, 'Personal Information'),
            _buildSettingsTile(Icons.security, 'Change Password'),
            _buildSettingsTile(Icons.notifications, 'Notifications'),
            _buildSettingsTile(Icons.language, 'Language'),
            _buildSettingsTile(Icons.help, 'Help & Support'),
            _buildSettingsTile(Icons.privacy_tip, 'Privacy Policy'),

            const Spacer(),

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

  Widget _buildSettingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to respective screen
      },
    );
  }
}