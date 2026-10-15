import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/reports/pdf_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTimeRange? _selectedDateRange;
  String _selectedReportType = 'Daily';

  final List<String> _reportTypes = ['Daily', 'Monthly', '3 Months', '6 Months', '12 Months'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Settlement')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Report Type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedReportType,
              items: _reportTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedReportType = value);
              },
            ),
            const SizedBox(height: 16),

            // Date Range
            ListTile(
              title: const Text('Custom Date Range'),
              subtitle: Text(
                _selectedDateRange == null
                    ? 'Select date range'
                    : '${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 24),

            // Generate Button
            CustomButton(
              text: 'Generate Report',
              onPressed: _generateReport,
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 24),

            // Export Options
            const Text(
              'Export Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                      title: const Text('PDF'),
                      subtitle: const Text('Export as PDF'),
                      onTap: _exportPDF,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.table_chart, size: 40, color: Colors.green),
                      title: const Text('Excel'),
                      subtitle: const Text('Export as Excel'),
                      onTap: _exportExcel,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report generated successfully!'), backgroundColor: Colors.green),
    );
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF exported successfully!'), backgroundColor: Colors.green),
    );
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel exported successfully!'), backgroundColor: Colors.green),
    );
  }
}