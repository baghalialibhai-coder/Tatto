// lib/widgets/common/date_range_picker.dart
import 'package:flutter/material.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(DateTimeRange?) onRangeSelected;
  final DateTimeRange? initialRange;

  const DateRangePickerWidget({
    super.key,
    required this.onRangeSelected,
    this.initialRange,
  });

  @override
  State<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedRange == null
                          ? 'Start Date - End Date'
                          : '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}',
                      style: TextStyle(
                        color: _selectedRange == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            if (_selectedRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRange = null;
                      widget.onRangeSelected(null);
                    });
                  },
                  child: const Text('Clear'),
                ),
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
      setState(() {
        _selectedRange = picked;
        widget.onRangeSelected(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}