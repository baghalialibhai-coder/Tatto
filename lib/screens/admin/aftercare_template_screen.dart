// lib/screens/admin/aftercare_template_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AftercareTemplateScreen extends StatefulWidget {
  const AftercareTemplateScreen({super.key});

  @override
  State<AftercareTemplateScreen> createState() => _AftercareTemplateScreenState();
}

class _AftercareTemplateScreenState extends State<AftercareTemplateScreen> {
  final _tattooAftercareController = TextEditingController(
    text: '''1. Keep the tattoo clean and dry for the first 24 hours.
2. Wash gently with mild soap and water.
3. Apply a thin layer of aftercare ointment.
4. Avoid direct sunlight for 2 weeks.
5. Do not scratch or pick the tattoo.
6. Wear loose clothing over the tattooed area.
7. Avoid swimming for 2 weeks.
8. Use unscented moisturizer after 3 days.
9. Do not use harsh chemicals on the area.
10. Contact us if you notice any signs of infection.''',
  );

  final _piercingAftercareController = TextEditingController(
    text: '''1. Clean piercing twice daily with saline solution.
2. Avoid touching with unwashed hands.
3. Do not rotate or twist jewelry.
4. Avoid sleeping on the piercing.
5. Avoid swimming for 4 weeks.
6. Keep hair away from new piercing.
7. Avoid makeup near the area.
8. Watch for signs of infection.
9. Wear loose clothing.
10. Follow up with your piercer after 4-6 weeks.''',
  );

  final _tattooRemovalController = TextEditingController(
    text: '''1. Keep the area clean and dry.
2. Apply ice packs to reduce swelling.
3. Use prescribed antibiotic ointment.
4. Avoid sun exposure for 4 weeks.
5. Do not pick at scabs.
6. Wear sunscreen (SPF 50+) when going out.
7. Follow up appointments as scheduled.
8. Contact us if you experience severe pain.''',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aftercare Templates'),
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
                'Aftercare Instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customize aftercare instructions for different services',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Tattoo Aftercare
              _buildSectionHeader('🎨 Tattoo Aftercare'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _tattooAftercareController,
                label: 'Tattoo Aftercare Instructions',
                hint: 'Enter tattoo aftercare instructions',
                icon: Icons.brush,
                maxLines: 10,
              ),

              const SizedBox(height: 24),

              // Piercing Aftercare
              _buildSectionHeader('💍 Piercing Aftercare'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _piercingAftercareController,
                label: 'Piercing Aftercare Instructions',
                hint: 'Enter piercing aftercare instructions',
                icon: Icons.circle,
                maxLines: 10,
              ),

              const SizedBox(height: 24),

              // Tattoo Removal Aftercare
              _buildSectionHeader('🧹 Tattoo Removal Aftercare'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _tattooRemovalController,
                label: 'Tattoo Removal Aftercare Instructions',
                hint: 'Enter tattoo removal aftercare instructions',
                icon: Icons.cleaning_services,
                maxLines: 10,
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Save Aftercare Templates',
                onPressed: _saveTemplates,
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
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

  void _saveTemplates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aftercare templates saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tattooAftercareController.dispose();
    _piercingAftercareController.dispose();
    _tattooRemovalController.dispose();
    super.dispose();
  }
}