// lib/providers/filter_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/consent_form_model.dart';
import '../core/enums/payment_status.dart';
import 'consent_form_provider.dart';

class FilterState {
  final String searchQuery;
  final String statusFilter;
  final String artistFilter;
  final DateTimeRange? dateRange;
  final String sortBy;
  final bool ascending;

  FilterState({
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.artistFilter = 'All',
    this.dateRange,
    this.sortBy = 'date',
    this.ascending = false,
  });

  FilterState copyWith({
    String? searchQuery,
    String? statusFilter,
    String? artistFilter,
    DateTimeRange? dateRange,
    String? sortBy,
    bool? ascending,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      artistFilter: artistFilter ?? this.artistFilter,
      dateRange: dateRange ?? this.dateRange,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setArtistFilter(String artist) {
    state = state.copyWith(artistFilter: artist);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void toggleSortOrder() {
    state = state.copyWith(ascending: !state.ascending);
  }

  void resetFilters() {
    state = FilterState();
  }

  List<ConsentFormModel> applyFilters(List<ConsentFormModel> forms) {
    var result = forms;

    // Search filter
    if (state.searchQuery.isNotEmpty) {
      result = result.where((form) =>
      form.customer.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          form.id.toLowerCase().contains(state.searchQuery.toLowerCase())
      ).toList();
    }

    // Status filter
    if (state.statusFilter != 'All') {
      result = result.where((form) =>
      form.payment.status.label == state.statusFilter
      ).toList();
    }

    // Artist filter
    if (state.artistFilter != 'All') {
      result = result.where((form) =>
      form.artistName == state.artistFilter
      ).toList();
    }

    // Date range filter
    if (state.dateRange != null) {
      result = result.where((form) {
        final date = form.appointment.date;
        // Add date comparison logic
        return true;
      }).toList();
    }

    // Sort
    if (state.sortBy == 'date') {
      result.sort((a, b) => state.ascending
          ? a.appointment.date.compareTo(b.appointment.date)
          : b.appointment.date.compareTo(a.appointment.date));
    } else if (state.sortBy == 'amount') {
      result.sort((a, b) => state.ascending
          ? a.payment.finalAmount.compareTo(b.payment.finalAmount)
          : b.payment.finalAmount.compareTo(a.payment.finalAmount));
    }

    return result;
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});


final filteredConsentFormsProvider = Provider<List<ConsentFormModel>>((ref) {
  final consentState = ref.watch(consentFormProvider); // Returns ConsentFormState
  final forms = consentState.forms; // ← Extract forms from state
  final filter = ref.watch(filterProvider);
  return ref.read(filterProvider.notifier).applyFilters(forms);
});