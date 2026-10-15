// lib/widgets/dashboard/recent_consent_card.dart
import 'package:flutter/material.dart';
import '../../core/enums/service_category.dart';
import '../../models/consent_form_model.dart';
import '../../core/enums/payment_status.dart';

class RecentConsentCard extends StatelessWidget {
  final ConsentFormModel consent;
  final VoidCallback? onTap;

  const RecentConsentCard({
    super.key,
    required this.consent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(consent.payment.status).withOpacity(0.2),
          child: Text(
            consent.customer.name[0].toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(consent.payment.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          consent.customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${consent.service.category.label} • ₹${consent.payment.finalAmount.toStringAsFixed(0)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(consent.payment.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            consent.payment.status.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap ?? () {
          // Show consent details
        },
      ),
    );
  }

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
}