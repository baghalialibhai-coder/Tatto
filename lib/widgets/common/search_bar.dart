// lib/widgets/common/search_bar.dart
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String hint;
  final Function(String) onChanged;
  final TextEditingController? controller;

  const SearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onChanged: onChanged,
    );
  }
}