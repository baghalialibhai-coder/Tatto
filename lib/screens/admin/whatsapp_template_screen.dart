// lib/screens/admin/whatsapp_template_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class WhatsAppTemplateScreen extends StatefulWidget {
  const WhatsAppTemplateScreen({super.key});

  @override
  State<WhatsAppTemplateScreen> createState() => _WhatsAppTemplateScreenState();
}

class _WhatsAppTemplateScreenState extends State<WhatsAppTemplateScreen> {
  final _greetingController = TextEditingController(
    text: '''Hi {{customer_name}},

Thank you for choosing The Temple of Tattooz!

Here are your service details:
- Service: {{service}}
- Artist: {{artist}}
- Amount: ₹{{amount}}
- Date: {{date}}
- Time: {{time}}''',
  );

  final _aftercareController = TextEditingController(
    text: '''Please follow the aftercare instructions carefully for best results.

Aftercare Guide: {{aftercare_link}}

Do's & Don'ts:
✅ Keep the area clean and dry
✅ Apply recommended ointment
✅ Wear loose clothing
❌ Don't scratch or pick
❌ Don't swim for 2 weeks
❌ Don't expose to direct sunlight''',
  );

  final _closingController = TextEditingController(
    text: '''For any questions, feel free to contact us at +91-XXXXXXXXXX

Thank you!
The Temple of Tattooz''',
  );

  bool _autoSendWhatsApp = true;
  bool _includeAftercareLink = true;
  bool _includePaymentLink = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Templates'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auto WhatsApp Message',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customize the auto WhatsApp message sent to customers',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Variables Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Variables:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '{{customer_name}} • {{service}} • {{artist}} • {{amount}}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '{{date}} • {{time}} • {{aftercare_link}}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Auto Send Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Auto Send WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Send message automatically after form submission'),
                  value: _autoSendWhatsApp,
                  onChanged: (value) => setState(() => _autoSendWhatsApp = value),
                  activeColor: Colors.green,
                ),
              ),

              const SizedBox(height: 16),

              // Include Aftercare Link
              SwitchListTile(
                title: const Text('Include Aftercare Link'),
                subtitle: const Text('Add aftercare guide link in message'),
                value: _includeAftercareLink,
                onChanged: (value) => setState(() => _includeAftercareLink = value),
              ),

              // Include Payment Link
              SwitchListTile(
                title: const Text('Include Payment Link'),
                subtitle: const Text('Add payment link in message'),
                value: _includePaymentLink,
                onChanged: (value) => setState(() => _includePaymentLink = value),
              ),

              const SizedBox(height: 16),

              // Greeting Message
              const Text(
                'Greeting Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _greetingController,
                label: 'Greeting',
                hint: 'Enter greeting message',
                icon: Icons.message,
                maxLines: 6,
              ),

              const SizedBox(height: 16),

              // Aftercare Message
              const Text(
                'Aftercare Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _aftercareController,
                label: 'Aftercare',
                hint: 'Enter aftercare instructions',
                icon: Icons.medical_services,
                maxLines: 8,
              ),

              const SizedBox(height: 16),

              // Closing Message
              const Text(
                'Closing Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _closingController,
                label: 'Closing',
                hint: 'Enter closing message',
                icon: Icons.thumb_up,
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save WhatsApp Templates',
                onPressed: _saveTemplates,
                backgroundColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTemplates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp templates saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _aftercareController.dispose();
    _closingController.dispose();
    super.dispose();
  }
}