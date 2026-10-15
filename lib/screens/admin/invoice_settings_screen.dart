// lib/screens/admin/invoice_settings_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class InvoiceSettingsScreen extends StatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  State<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends State<InvoiceSettingsScreen> {
  final _prefixController = TextEditingController(text: 'INV-');
  final _suffixController = TextEditingController(text: '');
  final _startNumberController = TextEditingController(text: '1001');
  final _footerController = TextEditingController(
    text: 'Thank you for choosing The Temple of Tattooz!\nWe hope to see you again.',
  );
  bool _includeTaxBreakdown = true;
  bool _includeQRCode = true;
  bool _includeSignature = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Settings'),
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
                'Invoice Number Format',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure how invoice numbers are generated',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Prefix & Suffix Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _prefixController,
                      label: 'Prefix',
                      hint: 'INV-',
                      icon: Icons.text_fields,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _suffixController,
                      label: 'Suffix',
                      hint: 'Optional',
                      icon: Icons.text_fields,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Start Number
              CustomTextField(
                controller: _startNumberController,
                label: 'Starting Number',
                hint: '1001',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),

              const Divider(height: 32),

              const Text(
                'Invoice Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customize what appears on your invoices',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Include Tax Breakdown
              SwitchListTile(
                title: const Text(
                  'Include Tax Breakdown',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Show CGST/SGST/IGST separately'),
                value: _includeTaxBreakdown,
                onChanged: (value) => setState(() => _includeTaxBreakdown = value),
              ),

              // Include QR Code
              SwitchListTile(
                title: const Text(
                  'Include QR Code',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Add payment QR code on invoice'),
                value: _includeQRCode,
                onChanged: (value) => setState(() => _includeQRCode = value),
              ),

              // Include Signature
              SwitchListTile(
                title: const Text(
                  'Include Signature',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Add customer signature on invoice'),
                value: _includeSignature,
                onChanged: (value) => setState(() => _includeSignature = value),
              ),

              const SizedBox(height: 16),

              // Footer
              const Text(
                'Invoice Footer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _footerController,
                label: 'Footer',
                hint: 'Enter thank you message',
                icon: Icons.format_quote,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Invoice Settings',
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
        content: Text('Invoice settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _suffixController.dispose();
    _startNumberController.dispose();
    _footerController.dispose();
    super.dispose();
  }
}