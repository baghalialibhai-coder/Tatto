// lib/screens/admin/settings_screen.dart
import 'package:flutter/material.dart';
import 'payment_methods_screen.dart';
import 'tax_settings_screen.dart';
import 'invoice_settings_screen.dart';
import 'whatsapp_template_screen.dart';
import 'aftercare_template_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Payment Settings'),
          _buildTile(
            Icons.payment,
            'Payment Methods',
            'Enable/disable payment methods',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
            ),
          ),
          _buildTile(
            Icons.percent,
            'Tax Settings',
            'Configure GST, CGST, SGST',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaxSettingsScreen()),
            ),
          ),
          _buildTile(
            Icons.receipt,
            'Invoice Settings',
            'Configure invoice format',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvoiceSettingsScreen()),
            ),
          ),

          const Divider(height: 32),

          _buildSection('Templates'),
          _buildTile(
            Icons.chat,
            'WhatsApp Templates',
            'Auto message templates',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WhatsAppTemplateScreen()),
            ),
          ),
          _buildTile(
            Icons.medical_services,
            'Aftercare Templates',
            'Tattoo & piercing aftercare',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AftercareTemplateScreen()),
            ),
          ),

          const Divider(height: 32),

          _buildSection('About'),
          _buildTile(
            Icons.info,
            'App Version',
            'Version 1.0.0',
                () {},
          ),
          _buildTile(
            Icons.privacy_tip,
            'Privacy Policy',
            'View privacy policy',
                () {},
          ),
          _buildTile(
            Icons.description,
            'Terms & Conditions',
            'View terms and conditions',
                () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
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

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}