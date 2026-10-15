// lib/screens/artist/artist_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/service_category.dart';
import '../../models/consent_form_model.dart';
import '../../providers/consent_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/enums/payment_status.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_button.dart';
import '../shared/consent_form_details_screen.dart';

class ArtistHistoryScreen extends ConsumerStatefulWidget {
  const ArtistHistoryScreen({super.key});

  @override
  ConsumerState<ArtistHistoryScreen> createState() => _ArtistHistoryScreenState();
}

class _ArtistHistoryScreenState extends ConsumerState<ArtistHistoryScreen> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  final List<String> _statusFilters = ['All', 'Paid', 'Partial', 'Pending'];

  @override
  Widget build(BuildContext context) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get artist's forms
    final allForms = consentState.forms
        .where((form) => form.artistId == user?.id)
        .toList();

    // Apply filters
    final artistForms = _applyFilters(allForms);

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
          : artistForms.isEmpty
          ? EmptyState(
        icon: Icons.history,
        title: 'No History Yet',
        subtitle: 'Your completed forms will appear here',
        buttonText: 'Create New Form',
        onButtonPressed: () {
          // Navigate to new form
          Navigator.pushNamed(context, '/artist/new-form');
        },
      )
          : Column(
        children: [
          // Filter chips
          if (_filterStatus != 'All' || _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterStatus != 'All')
                    Chip(
                      label: Text('Status: $_filterStatus'),
                      onDeleted: () {
                        setState(() => _filterStatus = 'All');
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  if (_searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Search: $_searchQuery'),
                      onDeleted: () {
                        setState(() => _searchQuery = '');
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                ],
              ),
            ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${artistForms.length} forms found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (artistForms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = 'All';
                        _searchQuery = '';
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
              itemCount: artistForms.length,
              itemBuilder: (context, index) {
                final form = artistForms[index];
                return _buildHistoryCard(form);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ConsentFormModel> _applyFilters(List<ConsentFormModel> forms) {
    var result = forms;

    // Status filter
    if (_filterStatus != 'All') {
      result = result.where((form) =>
      form.payment.status.label == _filterStatus
      ).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((form) =>
      form.customer.name.toLowerCase().contains(query) ||
          form.id.toLowerCase().contains(query) ||
          form.customer.mobile.contains(query)
      ).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) {
      try {
        final dateA = _parseDate(a.appointment.date as String);
        final dateB = _parseDate(b.appointment.date as String);
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

  Widget _buildHistoryCard(ConsentFormModel form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(form),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading icon
              CircleAvatar(
                radius: 28,
                backgroundColor: _getStatusColor(form.payment.status).withOpacity(0.15),
                child: Icon(
                  _getStatusIcon(form.payment.status),
                  color: _getStatusColor(form.payment.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            form.customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                    const SizedBox(height: 4),
                    Text(
                      'Service: ${form.service.category.label}',
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
                          form.appointment.date as String,
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

              // Amount
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
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade400,
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

  void _showDetails(ConsentFormModel form) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
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
                      form.customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                          form.customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          form.customer.mobile,
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
              _buildDetailSection('Service Details'),
              _buildDetailRow('Category', form.service.category.label),
              _buildDetailRow('Description', form.service.description),
              _buildDetailRow('Artist', form.artistName),
              const SizedBox(height: 16),

              _buildDetailSection('Appointment Details'),
              _buildDetailRow('Date', form.appointment.date as String),
              _buildDetailRow('Time', form.appointment.time),
              const SizedBox(height: 16),

              _buildDetailSection('Payment Details'),
              _buildDetailRow('Total Amount', '₹${form.payment.totalAmount.toStringAsFixed(0)}'),
              _buildDetailRow('Discount', '₹${form.payment.discount.toStringAsFixed(0)}'),
              _buildDetailRow('Final Amount', '₹${form.payment.finalAmount.toStringAsFixed(0)}'),
              _buildDetailRow('Payment Method', form.payment.methods.map((m) => m.label).join(', ')),
              const SizedBox(height: 16),

              _buildDetailSection('Health & Consent'),
              _buildDetailRow(
                'Health Conditions',
                form.healthConditions.isNotEmpty
                    ? form.healthConditions.join(', ')
                    : 'None',
              ),
              _buildDetailRow('Consent Signed', form.consentConfirmed ? 'Yes' : 'No'),
              _buildDetailRow('Aftercare Received', form.aftercareReceived ? 'Yes' : 'No'),
              const SizedBox(height: 16),

              _buildDetailSection('Timestamps'),
              _buildDetailRow('Created', _formatDateTime(form.createdAt)),
              if (form.submittedAt != null)
                _buildDetailRow('Submitted', _formatDateTime(form.submittedAt!)),

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
                      backgroundColor: Colors.blue,
                      icon: Icons.visibility,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Download PDF',
                      onPressed: () {
                        // Download PDF
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading PDF...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      icon: Icons.picture_as_pdf,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Share',
                      onPressed: () {
                        // Share
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon...'),
                          ),
                        );
                      },
                      icon: Icons.share,
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

  Widget _buildDetailSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Forms'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by customer name or ID',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Forms'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment Status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _statusFilters.map((status) {
                return FilterChip(
                  label: Text(status),
                  selected: _filterStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected ? status : 'All';
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}