// lib/widgets/common/filter_chip_group.dart
import 'package:flutter/material.dart';

class FilterChipGroup extends StatefulWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelected;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<FilterChipGroup> {
  String _selected = 'All';

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.options.map((option) {
        return FilterChip(
          label: Text(option),
          selected: _selected == option,
          onSelected: (value) {
            setState(() {
              _selected = value ? option : 'All';
              widget.onSelected(_selected);
            });
          },
        );
      }).toList(),
    );
  }
}