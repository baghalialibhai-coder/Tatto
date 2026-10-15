// lib/screens/admin/all_consent_forms_screen.dart
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/service_category.dart';
import '../../providers/artist_provider.dart';
import '../../providers/consent_form_provider.dart';
import '../../models/consent_form_model.dart';
import '../../core/enums/payment_status.dart';
import '../../core/enums/payment_method.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state.dart';
import '../shared/consent_form_details_screen.dart';

class AllConsentFormsScreen extends ConsumerStatefulWidget {
  const AllConsentFormsScreen({super.key});

  @override
  ConsumerState<AllConsentFormsScreen> createState() => _AllConsentFormsScreenState();
}

class _AllConsentFormsScreenState extends ConsumerState<AllConsentFormsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterArtist = 'All';
  DateTimeRange? _selectedDateRange;
  String _sortBy = 'date';
  bool _sortAscending = false;

  final List<String> _statusFilters = ['All', 'Paid', 'Partial', 'Pending'];
  final List<String> _sortOptions = ['Date', 'Amount', 'Customer'];
  List<String> _artistFilters = ['All'];

  @override
  Widget build(BuildContext context) {
    final consentState = ref.watch(consentFormProvider);
    final artists = ref.watch(artistProvider);

    // Update artist filters
    _artistFilters = ['All', ...artists.artists.map((a) => a.name).toList()];

    // Apply filters
    final filteredForms = _applyFilters(consentState.forms);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Consent Forms'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
            tooltip: 'Export',
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
          : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hint: 'Search by customer name or ID',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

          const SizedBox(height: 8),

          // Summary Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total', filteredForms.length.toString(), Icons.assignment),
                _buildStat('Revenue', '₹${_calculateTotal(filteredForms).toStringAsFixed(0)}', Icons.attach_money),
                _buildStat(
                  'Paid',
                  filteredForms.where((f) => f.payment.status == PaymentStatus.paid).length.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStat(
                  'Pending',
                  filteredForms.where((f) => f.payment.status == PaymentStatus.pending).length.toString(),
                  Icons.pending,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Active filters display
          if (_filterArtist != 'All' || _selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filterArtist != 'All')
                    Chip(
                      label: Text('Artist: $_filterArtist'),
                      onDeleted: () {
                        setState(() => _filterArtist = 'All');
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  if (_selectedDateRange != null)
                    Chip(
                      label: Text(
                        '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                      ),
                      onDeleted: () {
                        setState(() => _selectedDateRange = null);
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
                  '${filteredForms.length} results found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (filteredForms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterStatus = 'All';
                        _filterArtist = 'All';
                        _selectedDateRange = null;
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filteredForms.isEmpty
                ? EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No Consent Forms Found',
              subtitle: 'Try adjusting your filters or search query',
              buttonText: 'Clear Filters',
              onButtonPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterStatus = 'All';
                  _filterArtist = 'All';
                  _selectedDateRange = null;
                });
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredForms.length,
              itemBuilder: (context, index) {
                final form = filteredForms[index];
                return _buildFormCard(form);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.blue),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  List<ConsentFormModel> _applyFilters(List<ConsentFormModel> forms) {
    var result = forms;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((form) =>
      form.customer.name.toLowerCase().contains(query) ||
          form.id.toLowerCase().contains(query) ||
          form.customer.mobile.contains(query)
      ).toList();
    }

    // Status filter
    if (_filterStatus != 'All') {
      result = result.where((form) =>
      form.payment.status.label == _filterStatus
      ).toList();
    }

    // Artist filter
    if (_filterArtist != 'All') {
      result = result.where((form) =>
      form.artistName == _filterArtist
      ).toList();
    }

    // Date range filter
    if (_selectedDateRange != null) {
      result = result.where((form) {
        try {
          final dateParts = form.appointment.date.toString().split('-');
          if (dateParts.length == 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            final formDate = DateTime(year, month, day);
            return formDate.isAfter(_selectedDateRange!.start) &&
                formDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
          }
        } catch (e) {
          return false;
        }
        return false;
      }).toList();
    }

    // Sort
    result = _sortForms(result);

    return result;
  }

  List<ConsentFormModel> _sortForms(List<ConsentFormModel> forms) {
    final result = List<ConsentFormModel>.from(forms);

    switch (_sortBy) {
      case 'date':
        result.sort((a, b) {
          try {
            final dateA = _parseDate(a.appointment.date as String);
            final dateB = _parseDate(b.appointment.date as String);
            return _sortAscending
                ? dateA.compareTo(dateB)
                : dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'amount':
        result.sort((a, b) => _sortAscending
            ? a.payment.finalAmount.compareTo(b.payment.finalAmount)
            : b.payment.finalAmount.compareTo(a.payment.finalAmount));
        break;
      case 'customer':
        result.sort((a, b) => _sortAscending
            ? a.customer.name.compareTo(b.customer.name)
            : b.customer.name.compareTo(a.customer.name));
        break;
    }

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  double _calculateTotal(List<ConsentFormModel> forms) {
    return forms.fold(0.0, (sum, form) => sum + form.payment.finalAmount);
  }

  Widget _buildFormCard(ConsentFormModel form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(form.payment.status),
          child: Text(
            form.customer.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          form.customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${form.service.category.label}'),
            Text('Artist: ${form.artistName}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${form.payment.finalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Customer ID', form.id),
                _buildDetailRow('Customer Name', form.customer.name),
                _buildDetailRow('Mobile', form.customer.mobile),
                _buildDetailRow('Email', form.customer.email ?? 'N/A'),
                const Divider(),
                _buildDetailRow('Service', form.service.category.label),
                _buildDetailRow('Description', form.service.description),
                _buildDetailRow('Artist', form.artistName),
                const Divider(),
                _buildDetailRow('Date', form.appointment.date as String),
                _buildDetailRow('Time', form.appointment.time),
                const Divider(),
                _buildDetailRow('Total Amount', '₹${form.payment.totalAmount.toStringAsFixed(0)}'),
                _buildDetailRow('Discount', '₹${form.payment.discount.toStringAsFixed(0)}'),
                _buildDetailRow('Final Amount', '₹${form.payment.finalAmount.toStringAsFixed(0)}'),
                _buildDetailRow('Payment Status', form.payment.status.label),
                _buildDetailRow('Payment Method', form.payment.methods.map((m) => m.label).join(', ')),
                _buildDetailRow('Transaction ID', form.payment.id.isNotEmpty ? form.payment.id : 'N/A'),
                const Divider(),
                _buildDetailRow('Health Conditions', form.healthConditions.isNotEmpty ? form.healthConditions.join(', ') : 'None'),
                _buildDetailRow('Consent Signed', form.consentConfirmed ? '✅ Yes' : '❌ No'),
                if (form.notes != null && form.notes!.isNotEmpty)
                  _buildDetailRow('Notes', form.notes!),
                _buildDetailRow('Created', _formatDateTime(form.createdAt)),
                if (form.submittedAt != null)
                  _buildDetailRow('Submitted', _formatDateTime(form.submittedAt!)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _viewForm(form),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _downloadPDF(form),
                  icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                  label: const Text('PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                if (form.payment.status != PaymentStatus.paid)
                  TextButton.icon(
                    onPressed: () => _updatePayment(form),
                    icon: const Icon(Icons.payment, size: 18, color: Colors.orange),
                    label: const Text('Update Payment'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _sendWhatsApp(form),
                  icon: const Icon(Icons.chat, size: 18, color: Colors.green),
                  label: const Text('WhatsApp'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Filter Consent Forms'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Artist Filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Artist',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: _filterArtist,
                    items: _artistFilters.map((artist) {
                      return DropdownMenuItem(
                        value: artist,
                        child: Text(artist),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() => _filterArtist = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status Filter
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    value: _filterStatus,
                    items: _statusFilters.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() => _filterStatus = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Range
                  ListTile(
                    title: const Text('Date Range'),
                    subtitle: Text(
                      _selectedDateRange == null
                          ? 'Select date range'
                          : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() => _selectedDateRange = picked);
                      }
                    },
                    tileColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setStateDialog(() {
                    _filterArtist = 'All';
                    _filterStatus = 'All';
                    _selectedDateRange = null;
                  });
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Consent Forms'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort By
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sort),
              ),
              value: _sortBy,
              items: _sortOptions.map((option) {
                return DropdownMenuItem(
                  value: option.toLowerCase(),
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _sortBy = value!);
              },
            ),
            const SizedBox(height: 16),

            // Sort Order
            SwitchListTile(
              title: const Text('Ascending'),
              subtitle: Text(_sortAscending ? 'A to Z / Low to High' : 'Z to A / High to Low'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() => _sortAscending = value);
              },
              secondary: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Export as PDF'),
              subtitle: const Text('Download PDF report'),
              onTap: () {
                Navigator.pop(context);
                _exportPDF();
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              title: const Text('Export as Excel'),
              subtitle: const Text('Download Excel spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _exportExcel();
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.print, color: Colors.blue),
              ),
              title: const Text('Print'),
              subtitle: const Text('Print report directly'),
              onTap: () {
                Navigator.pop(context);
                _printReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Actions
  // ============================================================

  void _viewForm(ConsentFormModel form) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsentFormDetailsScreen(consentForm: form),
      ),
    );
  }

  void _downloadPDF(ConsentFormModel form) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download started...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement PDF download logic
  }

  void _updatePayment(ConsentFormModel form) {
    // Show payment update dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment update feature coming soon!'),
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
        '- Amount: ₹${form.payment.finalAmount}\n'
        '- Date: ${form.appointment.date}\n'
        '- Time: ${form.appointment.time}\n\n'
        'Please follow the aftercare instructions carefully.\n\n'
        'Thank you!\n'
        'The Temple of Tattooz';

    // Launch WhatsApp
    final url = Uri.parse(
      'https://wa.me/${form.customer.mobile}?text=${Uri.encodeComponent(message)}',
    );
    // Use url_launcher to launch
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export started...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement PDF export
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel export started...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement Excel export
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing report...'),
        backgroundColor: Colors.blue,
      ),
    );
    // Implement printing
  }
}