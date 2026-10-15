// lib/providers/consent_form_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/consent_form_model.dart';
import '../services/database/firestore_service.dart';

class ConsentFormState {
  final List<ConsentFormModel> forms;
  final bool isLoading;
  final String? error;
  final ConsentFormModel? selectedForm;

  ConsentFormState({
    this.forms = const [],
    this.isLoading = false,
    this.error,
    this.selectedForm,
  });

  ConsentFormState copyWith({
    List<ConsentFormModel>? forms,
    bool? isLoading,
    String? error,
    ConsentFormModel? selectedForm,
  }) {
    return ConsentFormState(
      forms: forms ?? this.forms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedForm: selectedForm ?? this.selectedForm,
    );
  }
}

class ConsentFormNotifier extends StateNotifier<ConsentFormState> {
  ConsentFormNotifier() : super(ConsentFormState());

  final FirestoreService _firestore = FirestoreService();

  // Load forms once (Future)
  Future<void> loadForms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final forms = await _firestore.getConsentForms(); // Now returns Future<List>
      state = state.copyWith(forms: forms, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load consent forms: $e',
      );
    }
  }

  // Stream forms (for real-time updates)
  Stream<List<ConsentFormModel>> streamForms() {
    return _firestore.streamConsentForms();
  }

  Future<void> submitConsentForm(ConsentFormModel form) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = await _firestore.saveConsentForm(form);
      final updatedForm = form.copyWith(
        id: id,
        status: 'submitted',
        submittedAt: DateTime.now(),
        isDraft: false,
      );
      // Reload forms after submission
      await loadForms();
      state = state.copyWith(
        isLoading: false,
        selectedForm: updatedForm,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit consent form: $e',
      );
      rethrow;
    }
  }

  Future<void> updateConsentForm(ConsentFormModel form) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestore.updateConsentForm(form);
      await loadForms(); // Reload after update
      state = state.copyWith(
        isLoading: false,
        selectedForm: form,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update consent form: $e',
      );
      rethrow;
    }
  }

  Future<void> deleteConsentForm(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestore.deleteConsentForm(id);
      await loadForms(); // Reload after delete
      state = state.copyWith(
        isLoading: false,
        selectedForm: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete consent form: $e',
      );
      rethrow;
    }
  }

  void selectForm(String id) {
    final form = state.forms.firstWhere((f) => f.id == id);
    state = state.copyWith(selectedForm: form);
  }

  void clearSelectedForm() {
    state = state.copyWith(selectedForm: null);
  }

  void saveDraft(ConsentFormModel form) {
    final draftForm = form.copyWith(isDraft: true, status: 'draft');
    final existingIndex = state.forms.indexWhere((f) => f.id == draftForm.id);

    if (existingIndex != -1) {
      final updatedForms = List<ConsentFormModel>.from(state.forms);
      updatedForms[existingIndex] = draftForm;
      state = state.copyWith(forms: updatedForms, selectedForm: draftForm);
    } else {
      state = state.copyWith(
        forms: [draftForm, ...state.forms],
        selectedForm: draftForm,
      );
    }
  }

  List<ConsentFormModel> getDrafts() {
    return state.forms.where((f) => f.isDraft).toList();
  }

  List<ConsentFormModel> getSubmitted() {
    return state.forms.where((f) => !f.isDraft).toList();
  }

  void reset() {
    state = ConsentFormState();
  }
}

// Provider for one-time fetch
final consentFormProvider = StateNotifierProvider<ConsentFormNotifier, ConsentFormState>((ref) {
  final notifier = ConsentFormNotifier();
  // Auto-load forms when provider is first used
  notifier.loadForms();
  return notifier;
});

// Provider for real-time stream
final consentFormStreamProvider = StreamProvider<List<ConsentFormModel>>((ref) {
  final notifier = ref.read(consentFormProvider.notifier);
  return notifier.streamForms();
});

// Provider to get only drafts
final draftsProvider = Provider<List<ConsentFormModel>>((ref) {
  final state = ref.watch(consentFormProvider);
  return state.forms.where((f) => f.isDraft).toList();
});

// Provider to get only submitted forms
final submittedFormsProvider = Provider<List<ConsentFormModel>>((ref) {
  final state = ref.watch(consentFormProvider);
  return state.forms.where((f) => !f.isDraft).toList();
});

// Provider to get forms by artist
final artistFormsProvider = Provider.family<List<ConsentFormModel>, String>((ref, artistId) {
  final state = ref.watch(consentFormProvider);
  return state.forms.where((f) => f.artistId == artistId).toList();
});

// Provider to get forms by customer
final customerFormsProvider = Provider.family<List<ConsentFormModel>, String>((ref, customerId) {
  final state = ref.watch(consentFormProvider);
  return state.forms.where((f) => f.customer.id == customerId).toList();
});

// Provider for loading state
final consentFormLoadingProvider = Provider<bool>((ref) {
  return ref.watch(consentFormProvider).isLoading;
});

// Provider for error state
final consentFormErrorProvider = Provider<String?>((ref) {
  return ref.watch(consentFormProvider).error;
});