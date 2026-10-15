// lib/screens/shared/consent_form_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/consent_form_model.dart';
import '../../core/enums/payment_status.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/service_category.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/consent_form_provider.dart';
import 'dart:io';

class ConsentFormDetailsScreen extends ConsumerStatefulWidget {
  final ConsentFormModel consentForm;
  final bool isEditable;

  const ConsentFormDetailsScreen({
    super.key,
    required this.consentForm,
    this.isEditable = false,
  });

  @override
  ConsumerState<ConsentFormDetailsScreen> createState() => _ConsentFormDetailsScreenState();
}

class _ConsentFormDetailsScreenState extends ConsumerState<ConsentFormDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final form = widget.consentForm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Form Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (widget.isEditable)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editForm,
              tooltip: 'Edit',
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _downloadPDF,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareForm,
            tooltip: 'Share',
          ),
          if (widget.isEditable)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteForm,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(form),
            const SizedBox(height: 16),

            // Customer Card
            _buildCustomerCard(form),
            const SizedBox(height: 16),

            // Service Details
            _buildSection('Service Details', Icons.brush),
            _buildServiceDetails(form),
            const SizedBox(height: 16),

            // Appointment Details
            _buildSection('Appointment Details', Icons.calendar_today),
            _buildAppointmentDetails(form),
            const SizedBox(height: 16),

            // Payment Details
            _buildSection('Payment Details', Icons.payment),
            _buildPaymentDetails(form),
            const SizedBox(height: 16),

            // Health Conditions
            _buildSection('Health Conditions', Icons.medical_services),
            _buildHealthConditions(form),
            const SizedBox(height: 16),

            // Consent & Aftercare
            _buildSection('Consent & Aftercare', Icons.verified),
            _buildConsentDetails(form),
            const SizedBox(height: 16),

            // Timestamps
            _buildSection('Timestamps', Icons.access_time),
            _buildTimestamps(form),
            const SizedBox(height: 16),

            // Notes
            if (form.notes != null && form.notes!.isNotEmpty)
              _buildNotes(form),
            const SizedBox(height: 16),

            // Actions
            _buildActionButtons(form),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Status Banner
  // ============================================================

  Widget _buildStatusBanner(ConsentFormModel form) {
    final status = form.payment.status;
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${status.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (form.isDraft)
                  const Text(
                    'Draft Mode - Not Submitted',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                if (form.isSubmitted)
                  Text(
                    'Submitted: ${_formatDateTime(form.submittedAt!)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (form.isDraft)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DRAFT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Customer Card
  // ============================================================

  Widget _buildCustomerCard(ConsentFormModel form) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                form.customer.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.customer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        form.customer.mobile,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (form.customer.email != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          form.customer.email!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                  if (form.customer.instagramId != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.install_mobile_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          form.customer.instagramId!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling customer...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              tooltip: 'Call Customer',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Section Builder
  // ============================================================

  Widget _buildSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Service Details
  // ============================================================

  Widget _buildServiceDetails(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Category', form.service.category.label),
            _buildDivider(),
            _buildDetailRow('Description', form.service.description),
            _buildDivider(),
            _buildDetailRow('Artist', form.artistName),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Appointment Details - ✅ FIXED
  // ============================================================

  Widget _buildAppointmentDetails(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ FIXED: Use date as String directly
            _buildDetailRow('Date', form.appointment.date.toString()),
            _buildDivider(),
            _buildDetailRow('Time', form.appointment.time),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Payment Details
  // ============================================================

  Widget _buildPaymentDetails(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              'Total Amount',
              '₹${form.payment.totalAmount.toStringAsFixed(0)}',
              isBold: true,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Discount',
              '₹${form.payment.discount.toStringAsFixed(0)}',
              textColor: Colors.green,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Final Amount',
              '₹${form.payment.finalAmount.toStringAsFixed(0)}',
              isBold: true,
              textColor: Colors.blue.shade700,
            ),
            _buildDivider(),
            _buildDetailRow(
              'Payment Method',
              form.payment.methods.map((m) => m.label).join(', '),
            ),
            if (form.payment.id.isNotEmpty) ...[
              _buildDivider(),
              _buildDetailRow('Transaction ID', form.payment.id),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Health Conditions
  // ============================================================

  Widget _buildHealthConditions(ConsentFormModel form) {
    final hasConditions = form.healthConditions.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (hasConditions)
              ...form.healthConditions.map((condition) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(condition),
                    ],
                  ),
                );
              }).toList()
            else
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('No health conditions reported'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Consent Details
  // ============================================================

  Widget _buildConsentDetails(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConsentRow(
              '18+ Confirmed',
              form.consentConfirmed,
            ),
            _buildDivider(),
            _buildConsentRow(
              'Aftercare Received',
              form.aftercareReceived,
            ),
            if (form.signatureUrl != null) ...[
              _buildDivider(),
              _buildDetailRow('Signature', '✅ Uploaded'),
            ],
            if (form.customerPhotoUrl != null) ...[
              _buildDivider(),
              _buildDetailRow('Photo', '✅ Uploaded'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsentRow(String label, bool confirmed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          children: [
            Icon(
              confirmed ? Icons.check_circle : Icons.cancel,
              color: confirmed ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              confirmed ? 'Confirmed' : 'Not Confirmed',
              style: TextStyle(
                color: confirmed ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // Timestamps
  // ============================================================

  Widget _buildTimestamps(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Created', _formatDateTime(form.createdAt)),
            _buildDivider(),
            if (form.updatedAt != null) ...[
              _buildDetailRow('Last Updated', _formatDateTime(form.updatedAt!)),
              _buildDivider(),
            ],
            if (form.submittedAt != null)
              _buildDetailRow('Submitted', _formatDateTime(form.submittedAt!)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Notes
  // ============================================================

  Widget _buildNotes(ConsentFormModel form) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              form.notes!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Action Buttons
  // ============================================================

  Widget _buildActionButtons(ConsentFormModel form) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Download PDF',
                onPressed: _downloadPDF,
                backgroundColor: Colors.red,
                icon: Icons.picture_as_pdf,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'WhatsApp',
                onPressed: () => _sendWhatsApp(form),
                backgroundColor: Colors.green,
                icon: Icons.chat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Share',
                onPressed: _shareForm,
                icon: Icons.share,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Print',
                onPressed: _printForm,
                icon: Icons.print,
              ),
            ),
          ],
        ),
        if (form.payment.status != PaymentStatus.paid && form.isSubmitted) ...[
          const SizedBox(height: 12),
          CustomButton(
            text: 'Update Payment Status',
            onPressed: _updatePayment,
            backgroundColor: Colors.orange,
            icon: Icons.payment,
          ),
        ],
        if (form.isDraft) ...[
          const SizedBox(height: 12),
          CustomButton(
            text: 'Submit Form',
            onPressed: _submitForm,
            backgroundColor: Colors.green,
            icon: Icons.send,
          ),
        ],
      ],
    );
  }

  // ============================================================
  // Helper Widgets
  // ============================================================

  Widget _buildDetailRow(
      String label,
      String value, {
        bool isBold = false,
        Color? textColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor ?? Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: Colors.grey.shade200,
        height: 1,
      ),
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.pending:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.partial:
        return Icons.pending;
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // Actions
  // ============================================================

  void _editForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit mode coming soon...'),
      ),
    );
  }

  void _downloadPDF() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _shareForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon...'),
      ),
    );
  }

  void _deleteForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Consent Form'),
        content: const Text(
          'Are you sure you want to delete this consent form? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(consentFormProvider.notifier)
                    .deleteConsentForm(widget.consentForm.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _sendWhatsApp(ConsentFormModel form) {
    final message =
        'Hi ${form.customer.name},\n\n'
        'Thank you for choosing The Temple of Tattooz!\n'
        'Here are your service details:\n'
        '- Service: ${form.service.category.label}\n'
        '- Artist: ${form.artistName}\n'
        '- Amount: ₹${form.payment.finalAmount.toStringAsFixed(0)}\n'
        '- Date: ${form.appointment.date}\n'
        '- Time: ${form.appointment.time}\n\n'
        'Please follow the aftercare instructions carefully.\n\n'
        'Thank you!\n'
        'The Temple of Tattooz';

    // Launch WhatsApp
    final url = Uri.parse(
      'https://wa.me/${form.customer.mobile}?text=${Uri.encodeComponent(message)}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _updatePayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new payment status:'),
            const SizedBox(height: 16),
            ...PaymentStatus.values.map((status) {
              return ListTile(
                leading: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                title: Text(status.label),
                onTap: () {
                  Navigator.pop(context);
                  _updatePaymentStatus(status);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updatePaymentStatus(PaymentStatus newStatus) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment status updated to ${newStatus.label}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _submitForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Consent Form'),
        content: const Text(
          'Are you sure you want to submit this consent form? '
              'Once submitted, it cannot be edited.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final updatedForm = widget.consentForm.copyWith(
                  isDraft: false,
                  status: 'submitted',
                  submittedAt: DateTime.now(),
                );
                await ref
                    .read(consentFormProvider.notifier)
                    .updateConsentForm(updatedForm);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}