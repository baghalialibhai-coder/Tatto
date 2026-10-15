// lib/screens/customer/customer_history_screen.dart
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

class CustomerHistoryScreen extends ConsumerStatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  ConsumerState<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends ConsumerState<CustomerHistoryScreen> {
  String _filterStatus = 'All';
  String _searchQuery = '';
  final List<String> _statusFilters = ['All', 'Paid', 'Partial', 'Pending'];

  @override
  Widget build(BuildContext context) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get customer's forms
    final allForms = consentState.forms
        .where((form) => form.customer.id == user?.id)
        .toList();

    // Apply filters
    final filteredForms = _applyFilters(allForms);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search',
          ),
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
        icon: Icons.history,
        title: 'No History Yet',
        subtitle: _searchQuery.isNotEmpty || _filterStatus != 'All'
            ? 'No forms match your search or filter.'
            : 'Your completed tattoo journey starts here.\nYour history will appear once you have appointments.',
        buttonText: 'Book an Appointment',
        onButtonPressed: () {
          Navigator.pushNamed(context, '/customer/new-form');
        },
      )
          : Column(
        children: [
          // Search bar (if search is active)
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search: $_searchQuery',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Filter chips
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
                  '${filteredForms.length} records found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if ((_searchQuery.isNotEmpty || _filterStatus != 'All') &&
                    filteredForms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterStatus = 'All';
                      });
                    },
                    child: const Text('Clear Filters'),
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
                return _buildHistoryCard(form);
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
    if (_filterStatus != 'All') {
      result = result.where((form) =>
      form.payment.status.label == _filterStatus).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((form) =>
      form.customer.name.toLowerCase().contains(query) ||
          form.id.toLowerCase().contains(query) ||
          form.service.category.label.toLowerCase().contains(query) ||
          form.artistName.toLowerCase().contains(query)).toList();
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

  // ============================================================
  // History Card
  // ============================================================

  Widget _buildHistoryCard(ConsentFormModel form) {
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
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(form.payment.status),
                  color: statusColor,
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

  // ============================================================
  // Search Dialog
  // ============================================================

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by service, artist, or customer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Filter Dialog
  // ============================================================

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment Status:'),
            const SizedBox(height: 8),
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
                contentPadding: EdgeInsets.zero,
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
        initialChildSize: 0.8,
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
                    backgroundColor: _getStatusColor(form.payment.status),
                    child: Text(
                      form.service.category.label[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.service.category.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Artist: ${form.artistName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(form.payment.status),
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
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Details
              _buildDetail('Customer', form.customer.name),
              _buildDetail('Mobile', form.customer.mobile),
              _buildDetail('Service', form.service.category.label),
              _buildDetail('Artist', form.artistName),
              _buildDetail('Date', form.appointment.date.toString()),
              _buildDetail('Time', form.appointment.time),
              _buildDetail('Amount', '₹${form.payment.finalAmount.toStringAsFixed(0)}'),
              _buildDetail('Payment Status', form.payment.status.label),
              _buildDetail(
                'Payment Method',
                form.payment.methods.map((m) => m.label).join(', '),
              ),
              _buildDetail(
                'Health Conditions',
                form.healthConditions.isNotEmpty
                    ? form.healthConditions.join(', ')
                    : 'None',
              ),
              _buildDetail('Consent Signed', form.consentConfirmed ? 'Yes' : 'No'),
              if (form.notes != null && form.notes!.isNotEmpty)
                _buildDetail('Notes', form.notes!),

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
                      text: 'Download PDF',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading PDF...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.picture_as_pdf,
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

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
}