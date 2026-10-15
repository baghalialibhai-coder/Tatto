// lib/screens/customer/customer_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/service_category.dart';
import '../../providers/consent_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/consent_form_model.dart';
import '../../core/enums/payment_status.dart';
import '../../core/enums/payment_method.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_button.dart';
import '../shared/consent_form_details_screen.dart';

class CustomerAppointmentsScreen extends ConsumerStatefulWidget {
  const CustomerAppointmentsScreen({super.key});

  @override
  ConsumerState<CustomerAppointmentsScreen> createState() => _CustomerAppointmentsScreenState();
}

class _CustomerAppointmentsScreenState extends ConsumerState<CustomerAppointmentsScreen> {
  String _filterStatus = 'All';
  final List<String> _statusFilters = ['All', 'Upcoming', 'Past', 'Paid', 'Pending'];

  @override
  Widget build(BuildContext context) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get customer's forms
    final allForms = consentState.forms
        .where((form) => form.customer.id == user?.id)
        .toList();

    // Apply filters and sort
    final filteredForms = _applyFilters(allForms);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(consentFormProvider.notifier).loadForms();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: consentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : consentState.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              consentState.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: () {
                ref.read(consentFormProvider.notifier).loadForms();
              },
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      )
          : filteredForms.isEmpty
          ? EmptyState(
        icon: Icons.calendar_today,
        title: 'No Appointments Found',
        subtitle: _filterStatus == 'All'
            ? 'You don\'t have any appointments yet.\nBook your first session today!'
            : 'No appointments match your filter.',
        buttonText: 'Book an Appointment',
        onButtonPressed: () {
          // Navigate to new consent form
          Navigator.pushNamed(context, '/customer/new-form');
        },
      )
          : Column(
        children: [
          // Status chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: _filterStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _filterStatus = selected ? status : 'All';
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: _filterStatus == status
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        fontWeight: _filterStatus == status
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredForms.length} appointments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (filteredForms.isNotEmpty && _filterStatus != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() => _filterStatus = 'All');
                    },
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredForms.length,
              itemBuilder: (context, index) {
                final form = filteredForms[index];
                return _buildAppointmentCard(form);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Filter Logic
  // ============================================================

  List<ConsentFormModel> _applyFilters(List<ConsentFormModel> forms) {
    var result = forms;

    // Status filter
    switch (_filterStatus) {
      case 'Upcoming':
        result = result.where((form) => _isUpcoming(form)).toList();
        break;
      case 'Past':
        result = result.where((form) => _isPast(form)).toList();
        break;
      case 'Paid':
        result = result.where((form) => form.payment.status == PaymentStatus.paid).toList();
        break;
      case 'Pending':
        result = result.where((form) => form.payment.status == PaymentStatus.pending).toList();
        break;
      default:
        break;
    }

    // Sort by date (newest first)
    result.sort((a, b) {
      try {
        final dateA = _parseDate(a.appointment.date.toString());
        final dateB = _parseDate(b.appointment.date.toString());
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return result;
  }

  bool _isUpcoming(ConsentFormModel form) {
    try {
      final date = _parseDate(form.appointment.date.toString());
      final now = DateTime.now();
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _parseTime(form.appointment.time),
      );
      return dateTime.isAfter(now) || dateTime.isAtSameMomentAs(now);
    } catch (e) {
      return false;
    }
  }

  bool _isPast(ConsentFormModel form) {
    try {
      final date = _parseDate(form.appointment.date.toString());
      final now = DateTime.now();
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _parseTime(form.appointment.time),
      );
      return dateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      }
      if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      return hour;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // Appointment Card
  // ============================================================

  Widget _buildAppointmentCard(ConsentFormModel form) {
    final isUpcoming = _isUpcoming(form);
    final statusColor = _getStatusColor(form.payment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(context, form),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.blue.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUpcoming ? Icons.event_available : Icons.event_busy,
                  color: isUpcoming ? Colors.blue : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.service.category.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artist: ${form.artistName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          form.appointment.date.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          form.appointment.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${form.payment.finalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      form.payment.status.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isUpcoming)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

  // ============================================================
  // Filter Dialog
  // ============================================================

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select filter:'),
            const SizedBox(height: 16),
            ..._statusFilters.map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: Colors.blue,
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterStatus = 'All');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Details Bottom Sheet
  // ============================================================

  void _showDetails(BuildContext context, ConsentFormModel form) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      form.customer.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
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
                        Text(
                          form.service.category.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(form.payment.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      form.payment.status.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Details
              _buildDetailRow('Artist', form.artistName),
              _buildDetailRow('Date', form.appointment.date.toString()),
              _buildDetailRow('Time', form.appointment.time),
              _buildDetailRow('Amount', '₹${form.payment.finalAmount.toStringAsFixed(0)}'),
              _buildDetailRow('Payment Method', form.payment.methods.map((m) => m.label).join(', ')),
              _buildDetailRow('Status', form.payment.status.label),
              if (form.notes != null && form.notes!.isNotEmpty)
                _buildDetailRow('Notes', form.notes!),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'View Full Details',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConsentFormDetailsScreen(
                              consentForm: form,
                            ),
                          ),
                        );
                      },
                      icon: Icons.visibility,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'WhatsApp',
                      onPressed: () => _sendWhatsApp(form),
                      backgroundColor: Colors.green,
                      icon: Icons.chat,
                      isOutlined: true,
                      textColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WhatsApp Action
  // ============================================================

  void _sendWhatsApp(ConsentFormModel form) {
    final message =
        'Hi ${form.customer.name},\n\n'
        'Here are your appointment details at The Temple of Tattooz:\n'
        '- Service: ${form.service.category.label}\n'
        '- Artist: ${form.artistName}\n'
        '- Date: ${form.appointment.date}\n'
        '- Time: ${form.appointment.time}\n'
        '- Amount: ₹${form.payment.finalAmount.toStringAsFixed(0)}\n\n'
        'Please arrive 10 minutes before your appointment.\n\n'
        'Thank you!\n'
        'The Temple of Tattooz';

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
}