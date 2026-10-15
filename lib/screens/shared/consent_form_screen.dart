import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tattoo/models/consent_form_model.dart';
import '../../widgets/consent_form/customer_details_section.dart';
import '../../widgets/consent_form/service_details_section.dart';
import '../../widgets/consent_form/appointment_details_section.dart';
import '../../widgets/consent_form/payment_details_section.dart';
import '../../widgets/consent_form/consent_acknowledgement_section.dart';
import '../../widgets/consent_form/declaration_section.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/consent_form_provider.dart';

class ConsentFormScreen extends ConsumerStatefulWidget {
  const ConsentFormScreen({super.key});

  @override
  ConsumerState<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends ConsumerState<ConsentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(consentFormProvider);
    final formController = ref.read(consentFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Form'),
        actions: [
          TextButton(
            onPressed: () {
              // Save draft
              formController.saveDraft(context as ConsentFormModel);
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      'THE TEMPLE OF TATTOOZ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chosen By Legends, Inked By Pros',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2 BRANCHES : AKOTA & JUBELIBAUGH',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Divider(height: 32),
                  ],
                ),
              ),

              // // Sections
              // CustomerDetailsSection(),
              // const SizedBox(height: 24),
              // ServiceDetailsSection(),
              // const SizedBox(height: 24),
              // AppointmentDetailsSection(),
              // const SizedBox(height: 24),
              // PaymentDetailsSection(),
              // const SizedBox(height: 24),
              // HealthConditionsSection(),
              // const SizedBox(height: 24),
              // ConsentAcknowledgementSection(),
              // const SizedBox(height: 24),
              // DeclarationSection(),
              // const SizedBox(height: 32),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IMPORTANT NOTICE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To Ensure the Best Results & Maintain The Quality Of Our Service,\n'
                          'The Purchase Of Aftercare Products Valued At 500 INR is Mandatory,\n'
                          'By Proceeding With Our Service, You Agree To This Condition.',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NO REFUNDS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Row(
                children: [
                  // Expanded(
                  //   child: CustomButton(
                  //     text: 'Submit Consent Form',
                  //     isLoading: _isSubmitting,
                  //     onPressed: _submitForm,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _submitForm() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }
  //
  //   setState(() => _isSubmitting = true);
  //   try {
  //     final controller = ref.read(consentFormProvider.notifier);
  //     await controller.submitConsentForm();
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Consent form submitted successfully!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  //   setState(() => _isSubmitting = false);
  // }
}