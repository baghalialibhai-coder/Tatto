// lib/screens/admin/tax_settings_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
  final _gstController = TextEditingController(text: '18');
  final _cgstController = TextEditingController(text: '9');
  final _sgstController = TextEditingController(text: '9');
  final _igstController = TextEditingController(text: '18');
  bool _showTaxOnDiscount = false;
  bool _isGSTApplicable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GST / Tax Configuration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure tax settings for your studio',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Enable GST Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Enable GST/Tax',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Apply tax to all services'),
                  value: _isGSTApplicable,
                  onChanged: (value) => setState(() => _isGSTApplicable = value),
                  activeColor: Colors.blue,
                ),
              ),

              const Divider(height: 32),

              if (_isGSTApplicable) ...[
                const Text(
                  'Tax Rates',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Total GST
                CustomTextField(
                  controller: _gstController,
                  label: 'Total GST Rate (%)',
                  hint: 'Enter total GST percentage',
                  icon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // CGST & SGST Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cgstController,
                        label: 'CGST (%)',
                        hint: 'Central GST',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _sgstController,
                        label: 'SGST (%)',
                        hint: 'State GST',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // IGST
                CustomTextField(
                  controller: _igstController,
                  label: 'IGST (%)',
                  hint: 'Integrated GST',
                  icon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Apply Tax on Discount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Apply Tax on Discount',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Calculate tax after discount'),
                    value: _showTaxOnDiscount,
                    onChanged: (value) => setState(() => _showTaxOnDiscount = value),
                    activeColor: Colors.blue,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Tax Settings',
                onPressed: _saveSettings,
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _gstController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    super.dispose();
  }
}