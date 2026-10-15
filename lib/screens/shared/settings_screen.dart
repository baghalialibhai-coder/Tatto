import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('General'),
          _buildSettingsTile(Icons.color_lens, 'Theme', 'Dark/Light'),
          _buildSettingsTile(Icons.language, 'Language', 'English'),
          _buildSettingsTile(Icons.notifications, 'Notifications', 'On'),

          const Divider(),
          _buildSettingsSection('Studio Settings'),
          _buildSettingsTile(Icons.store, 'Studio Information', ''),
          _buildSettingsTile(Icons.attach_money, 'Currency', 'INR'),
          _buildSettingsTile(Icons.percent, 'Tax Rate', '18%'),

          const Divider(),
          _buildSettingsSection('About'),
          _buildSettingsTile(Icons.info, 'App Version', '1.0.0'),
          _buildSettingsTile(Icons.privacy_tip, 'Privacy Policy', ''),
          _buildSettingsTile(Icons.description, 'Terms & Conditions', ''),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}