// lib/screens/customer/customer_consent_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/artist_model.dart';
import '../../models/branch_model.dart';
import '../../models/consent_form_model.dart';
import '../../models/customer_model.dart';
import '../../models/service_model.dart';
import '../../models/appointment_model.dart';
import '../../models/payment_model.dart';
import '../../core/enums/service_category.dart';
import '../../core/enums/payment_method.dart';
import '../../core/enums/payment_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consent_form_provider.dart';
import '../../services/database/firestore_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'dart:io';

class CustomerConsentFormScreen extends ConsumerStatefulWidget {
  final ConsentFormModel? existingForm;

  const CustomerConsentFormScreen({super.key, this.existingForm});

  @override
  ConsumerState<CustomerConsentFormScreen> createState() =>
      _CustomerConsentFormScreenState();
}

class _CustomerConsentFormScreenState
    extends ConsumerState<CustomerConsentFormScreen> {
  // ============================================================
  // Form Controllers
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // Customer Details
  final _customerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _instagramController = TextEditingController();

  // Service Details
  ServiceCategory? _selectedCategory;
  final _serviceDescriptionController = TextEditingController();
  String _selectedArtistId = '';
  String _selectedArtistName = '';

  // Branch Selection
  String _selectedBranchId = '';
  String _selectedBranchName = '';
  String _selectedBranchAddress = '';
  List<BranchModel> _branches = [];
  bool _branchesLoading = true;

  // Appointment Details
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '05:30 PM';

  // Payment Details
  final _totalAmountController = TextEditingController();
  final _discountController = TextEditingController();
  final _finalAmountController = TextEditingController();
  List<PaymentMethod> _selectedPaymentMethods = [];
  PaymentStatus _selectedPaymentStatus = PaymentStatus.pending;
  final _transactionIdController = TextEditingController();

  // Health Conditions
  List<String> _selectedHealthConditions = [];

  // Consent
  bool _consentConfirmed = false;
  bool _declarationAccepted = false;

  // Files
  File? _signatureFile;
  File? _customerPhotoFile;
  String? _signatureUrl;
  String? _customerPhotoUrl;

  // Studio Use
  final _invoiceValueController = TextEditingController();
  String _selectedPaymentMode = 'Cash';
  final _advancePaymentController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedReceivedBy = '';
  final _notesController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Available Artists
  List<ArtistModel> _artists = [];
  List<String> _artistNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.existingForm != null) {
      _loadExistingForm(widget.existingForm!);
    }
  }

  // ============================================================
  // Load Data
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _branchesLoading = true;
    });
    try {
      final firestore = FirestoreService();

      // Load Branches
      _branches = await firestore.getBranches();
      if (_branches.isNotEmpty) {
        _selectedBranchId = _branches.first.id;
        _selectedBranchName = _branches.first.name;
        _selectedBranchAddress = _branches.first.address;
      }
      setState(() => _branchesLoading = false);

      // Load Artists
      _artists = await firestore.getActiveArtists();
      _artistNames = _artists.map((a) => a.name).toList();

      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _branchesLoading = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadExistingForm(ConsentFormModel form) {
    _customerNameController.text = form.customer.name;
    _mobileController.text = form.customer.mobile;
    _instagramController.text = form.customer.instagramId ?? '';
    _selectedCategory = form.service.category;
    _serviceDescriptionController.text = form.service.description;
    _selectedArtistId = form.artistId;
    _selectedArtistName = form.artistName;
    _selectedDate = form.appointment.date;
    _selectedTime = form.appointment.time;
    _totalAmountController.text = form.payment.totalAmount.toString();
    _discountController.text = form.payment.discount.toString();
    _finalAmountController.text = form.payment.finalAmount.toString();
    _selectedPaymentMethods = form.payment.methods;
    _selectedPaymentStatus = form.payment.status;
    _transactionIdController.text = form.payment.transactionId;
    _selectedHealthConditions = form.healthConditions;
    _consentConfirmed = form.consentConfirmed;
    _declarationAccepted = form.consentConfirmed;
  }

  // ============================================================
  // Build Method
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingForm != null
              ? 'Edit Consent Form'
              : 'New Consent Form',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSection('1. BASIC CUSTOMER DETAILS'),
                    _buildCustomerDetails(),
                    _buildSection('2. SERVICE DETAILS'),
                    _buildServiceDetails(),
                    _buildSection('3. APPOINTMENT DETAILS'),
                    _buildAppointmentDetails(),
                    _buildSection('4. PAYMENT DETAILS'),
                    _buildPaymentDetails(),
                    _buildSection('5. MEDICAL & HEALTH CONDITIONS'),
                    _buildHealthConditions(),
                    _buildSection('6. CONSENT & ACKNOWLEDGEMENT'),
                    _buildConsent(),
                    _buildSection('7. DECLARATION & AGREEMENT'),
                    _buildDeclaration(),
                    _buildImportantNotice(),
                    _buildSection('8. FOR STUDIO USE ONLY'),
                    _buildStudioUse(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // Header & Section
  // ============================================================

  Widget _buildHeader() {
    return const Center(
      child: Column(
        children: [
          Text(
            'THE TEMPLE OF TATTOOZ',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            'Chosen By Legends, Inked By Pros',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '2 BRANCHES : AKOTA & JUBELIBAUGH',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // ============================================================
  // 1. Customer Details Section
  // ============================================================

  Widget _buildCustomerDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _customerNameController,
              label: 'Customer Name *',
              hint: 'Enter Name',
              icon: Icons.person,
              validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _mobileController,
              label: 'Mobile Number *',
              hint: 'Enter Mobile Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Mobile is required' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _instagramController,
              label: 'Instagram ID (Optional)',
              hint: '@username',
              icon: Icons.camera_alt,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. Service Details Section
  // ============================================================

  Widget _buildServiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Branch *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              value: _selectedBranchId.isNotEmpty ? _selectedBranchId : null,
              items: _branches.map((branch) {
                return DropdownMenuItem(
                  value: branch.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        branch.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final branch = _branches.firstWhere((b) => b.id == value);
                  setState(() {
                    _selectedBranchId = value;
                    _selectedBranchName = branch.name;
                    _selectedBranchAddress = branch.address;
                    _selectedArtistId = '';
                    _selectedArtistName = '';
                  });
                }
              },
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Please select a branch' : null,
            ),
            const SizedBox(height: 12),

            // Selected Branch Info
            if (_selectedBranchName.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBranchName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            _selectedBranchAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Category Selector Cards
            _buildCategorySelector(),
            const SizedBox(height: 12),

            // Service Description
            CustomTextField(
              controller: _serviceDescriptionController,
              label: 'Tattoo / Service Description *',
              hint: 'Enter Details',
              icon: Icons.description,
              maxLines: 3,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Description is required' : null,
            ),
            const SizedBox(height: 12),

            // Artist Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Artist *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              value: _selectedArtistName.isNotEmpty
                  ? _selectedArtistName
                  : null,
              items: _getFilteredArtists().map((artist) {
                return DropdownMenuItem(
                  value: artist.name,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          artist.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (artist.specialty != null)
                              Text(
                                artist.specialty!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final artist = _artists.firstWhere((a) => a.name == value);
                  setState(() {
                    _selectedArtistName = value;
                    _selectedArtistId = artist.id;
                  });
                }
              },
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Please select an artist' : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Category Selector Cards
  // ============================================================

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Category *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ServiceCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return _buildCategoryCard(category, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ServiceCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 20,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.tattoo:
        return Icons.brush;
      case ServiceCategory.piercing:
        return Icons.circle;
      case ServiceCategory.temporary:
        return Icons.style;
      case ServiceCategory.removal:
        return Icons.cleaning_services;
      case ServiceCategory.other:
        return Icons.more_horiz;
    }
  }

  List<ArtistModel> _getFilteredArtists() {
    if (_selectedBranchId.isEmpty) return _artists;
    return _artists
        .where(
          (artist) =>
              artist.branchId == _selectedBranchId || artist.branchId.isEmpty,
        )
        .toList();
  }

  // ============================================================
  // 3. Appointment Details Section
  // ============================================================

  Widget _buildAppointmentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date *'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: _selectDate,
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time *'),
              subtitle: Text(_selectedTime),
              onTap: _selectTime,
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 4. Payment Details Section
  // ============================================================

  Widget _buildPaymentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _totalAmountController,
              label: 'Total Amount (₹) *',
              hint: 'Enter Amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateFinalAmount(),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Amount is required' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _discountController,
              label: 'Discount (₹)',
              hint: 'Enter Discount',
              icon: Icons.discount,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateFinalAmount(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _finalAmountController,
              label: 'Final Amount (₹) *',
              hint: 'Enter Final Amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              readOnly: true,
              fillColor: Colors.grey.shade100,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Final amount is required' : null,
            ),
            const SizedBox(height: 12),
            const Text(
              'Payment Method *',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PaymentMethod.values.map((method) {
                final isSelected = _selectedPaymentMethods.contains(method);
                return FilterChip(
                  label: Text(method.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPaymentMethods.add(method);
                      } else {
                        _selectedPaymentMethods.remove(method);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _transactionIdController,
              label: 'Transaction ID',
              hint: 'Enter Reference / Transaction ID',
              icon: Icons.receipt,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentStatus>(
              decoration: const InputDecoration(
                labelText: 'Payment Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              value: _selectedPaymentStatus,
              items: PaymentStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null)
                  setState(() => _selectedPaymentStatus = value);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Payment Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: _selectDate,
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 5. Health Conditions Section
  // ============================================================

  Widget _buildHealthConditions() {
    final List<String> allConditions = [
      'Diabetes',
      'HIV',
      'Skin Conditions',
      'Under Influence of Alcohol or Drugs',
      'High Blood Pressure / Heart Conditions',
      'Pregnant / Nursing',
      'Allergies',
      'None of the Above',
      'Fainting / Seizures / Epilepsy',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Please tick all that apply',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allConditions.map((condition) {
                final isSelected = _selectedHealthConditions.contains(
                  condition,
                );
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedHealthConditions.add(condition);
                      } else {
                        _selectedHealthConditions.remove(condition);
                      }
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.orange.shade100,
                );
              }).toList(),
            ),
            if (_selectedHealthConditions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please inform the artist about these conditions.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 6. Consent Section
  // ============================================================

  Widget _buildConsent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCheckboxTile(
              'I confirm that I am 18 years or older.',
              _consentConfirmed,
              (v) => setState(() => _consentConfirmed = v ?? false),
            ),
            _buildCheckboxTile(
              'I confirm that I have read and understood the information about the service, risks, aftercare and instructions.',
              _consentConfirmed,
              (v) => setState(() => _consentConfirmed = v ?? false),
            ),
            _buildCheckboxTile(
              'I agree to the terms & conditions.',
              _consentConfirmed,
              (v) => setState(() => _consentConfirmed = v ?? false),
            ),
            _buildCheckboxTile(
              'I understand that results may vary from person to person.',
              _consentConfirmed,
              (v) => setState(() => _consentConfirmed = v ?? false),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickSignature,
                    icon: const Icon(Icons.edit),
                    label: const Text('Add Signature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_signatureFile != null || _customerPhotoFile != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (_signatureFile != null)
                    Chip(
                      label: const Text('Signature Added'),
                      avatar: const Icon(Icons.check, color: Colors.green),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _signatureFile = null),
                    ),
                  if (_customerPhotoFile != null)
                    Chip(
                      label: const Text('Photo Added'),
                      avatar: const Icon(Icons.check, color: Colors.green),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () =>
                          setState(() => _customerPhotoFile = null),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 7. Declaration Section
  // ============================================================

  Widget _buildDeclaration() {
    final declarations = [
      'I understand that tattooing carries risks such as infection, allergic reactions, scarring, fading, or dissatisfaction with results.',
      'I have disclosed all medical conditions and accept responsibility for proper aftercare.',
      'Tattoo results vary by skin type, healing, and body response.',
      'Touch-ups must be done within 3 months; later or repeated ones are chargeable.',
      'Tattoos on fingers, palms, lips, or similar areas fade faster and require paid work.',
      'All payments are strictly non-refundable and non-transferable, regardless of design, size, placement changes, or if I stop midway.',
      'I permit The Temple of Tattooz to use tattoo images/video for portfolio and promotions.',
      'I accept the possibility of pain, dizziness, or fainting and release the artist/studio from liability.',
      'I confirm I am 18+ and fully responsible for choosing to be tattooed, releasing the studio and artists from any claims.',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: declarations.map((text) {
            return _buildCheckboxTile(text, _declarationAccepted, (v) {
              setState(() => _declarationAccepted = v ?? false);
            });
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // Important Notice
  // ============================================================

  Widget _buildImportantNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ IMPORTANT NOTICE',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          SizedBox(height: 8),
          Text(
            'To Ensure the Best Results & Maintain The Quality Of Our Service,\n'
            'The Purchase Of Aftercare Products Valued At 500 INR is Mandatory,\n'
            'By Proceeding With Our Service, You Agree To This Condition.',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            '🔴 NO REFUNDS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 8. Studio Use Section
  // ============================================================

  Widget _buildStudioUse() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _invoiceValueController,
                    label: 'Invoice Value (₹)',
                    hint: 'Enter Invoice Value',
                    icon: Icons.receipt,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    value: _selectedPaymentMode,
                    items: ['Cash', 'UPI', 'Card', 'Online', 'Other'].map((
                      mode,
                    ) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedPaymentMode = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _advancePaymentController,
                    label: 'Advance Payment (₹)',
                    hint: 'Enter Advance Amount',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _balanceController,
                    label: 'Balance (₹)',
                    hint: 'Enter Balance Amount',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Received By',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    value: _selectedReceivedBy.isNotEmpty
                        ? _selectedReceivedBy
                        : null,
                    items: _artistNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedReceivedBy = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Enter Notes',
                    icon: Icons.note,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Submit Button
  // ============================================================

  Widget _buildSubmitButton() {
    return CustomButton(
      text: widget.existingForm != null
          ? 'Update Consent Form'
          : 'Submit Consent Form',
      isLoading: _isSubmitting,
      onPressed: _submitForm,
      backgroundColor: Colors.blue,
      icon: Icons.send,
    );
  }

  // ============================================================
  // Helper Widgets
  // ============================================================

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  void _updateFinalAmount() {
    final total = double.tryParse(_totalAmountController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final finalAmount = total - discount;
    _finalAmountController.text = finalAmount.toStringAsFixed(0);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_selectedTime.split(':')[0]),
        minute: int.parse(_selectedTime.split(':')[1].split(' ')[0]),
      ),
    );
    if (picked != null) {
      final ampm = picked.hour >= 12 ? 'PM' : 'AM';
      final hour = picked.hour > 12 ? picked.hour - 12 : picked.hour;
      setState(() {
        _selectedTime =
            '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $ampm';
      });
    }
  }

  Future<void> _pickSignature() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signature picker coming soon!')),
    );
  }

  Future<void> _pickPhoto() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo picker coming soon!')));
  }

  // ============================================================
  // Save Draft
  // ============================================================

  void _saveDraft() {
    if (!_validateForm(showErrors: false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill required fields before saving draft'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final form = _buildConsentForm(isDraft: true);
      final controller = ref.read(consentFormProvider.notifier);
      controller.saveDraft(form);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving draft: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Submit Form
  // ============================================================

  Future<void> _submitForm() async {
    if (!_validateForm(showErrors: true)) return;

    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the declaration to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_consentConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm consent to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final form = _buildConsentForm(isDraft: false);
      final controller = ref.read(consentFormProvider.notifier);

      if (widget.existingForm != null) {
        await controller.updateConsentForm(form);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consent form updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await controller.submitConsentForm(form);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consent form submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ============================================================
  // Validation
  // ============================================================

  bool _validateForm({bool showErrors = true}) {
    bool isValid = true;
    String errorMessage = '';

    if (_customerNameController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Customer name is required';
    } else if (_mobileController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Mobile number is required';
    } else if (_selectedBranchId.isEmpty) {
      isValid = false;
      errorMessage = 'Please select a branch';
    } else if (_selectedArtistName.isEmpty) {
      isValid = false;
      errorMessage = 'Please select an artist';
    } else if (_selectedCategory == null) {
      isValid = false;
      errorMessage = 'Please select a service category';
    } else if (_serviceDescriptionController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Service description is required';
    } else if (_totalAmountController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Total amount is required';
    } else if (_selectedPaymentMethods.isEmpty) {
      isValid = false;
      errorMessage = 'Please select at least one payment method';
    }

    if (!isValid && showErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }

    return isValid;
  }

  // ============================================================
  // Build Consent Form Model
  // ============================================================

  ConsentFormModel _buildConsentForm({required bool isDraft}) {
    final customer = CustomerModel(
      id: widget.existingForm?.customer.id ?? '',
      name: _customerNameController.text.trim(),
      mobile: _mobileController.text.trim(),
      instagramId: _instagramController.text.trim().isNotEmpty
          ? _instagramController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    final service = ServiceModel(
      id: widget.existingForm?.service.id ?? '',
      category: _selectedCategory!,
      name: _selectedCategory!.label,
      description: _serviceDescriptionController.text.trim(),
      basePrice: double.tryParse(_totalAmountController.text) ?? 0,
      createdAt: DateTime.now(),
    );

    final appointment = AppointmentModel(
      id: widget.existingForm?.appointment.id ?? '',
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.mobile,
      branchId: _selectedBranchId,
      branchName: _selectedBranchName,
      artistId: _selectedArtistId,
      artistName: _selectedArtistName,
      serviceId: service.id,
      serviceName: service.name,
      date: _selectedDate,
      time: _selectedTime,
      duration: 60,
      amount: double.tryParse(_totalAmountController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      finalAmount: double.tryParse(_finalAmountController.text) ?? 0,
      createdAt: DateTime.now(),
    );

    final payment = PaymentModel(
      id: widget.existingForm?.payment.id ?? '',
      consentFormId: '',
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      finalAmount: double.tryParse(_finalAmountController.text) ?? 0,
      methods: _selectedPaymentMethods,
      status: _selectedPaymentStatus,
      paymentDate: _selectedDate,
      transactionId: _transactionIdController.text.trim(),
      createdAt: DateTime.now(),
    );

    return ConsentFormModel(
      id: widget.existingForm?.id ?? '',
      customer: customer,
      service: service,
      appointment: appointment,
      payment: payment,
      artistId: _selectedArtistId,
      artistName: _selectedArtistName,
      healthConditions: _selectedHealthConditions,
      consentConfirmed: _consentConfirmed,
      signatureUrl: _signatureUrl,
      customerPhotoUrl: _customerPhotoUrl,
      aftercareReceived: false,
      isDraft: isDraft,
      status: isDraft ? 'draft' : 'submitted',
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: widget.existingForm?.createdAt ?? DateTime.now(),
      submittedAt: isDraft ? null : DateTime.now(),
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileController.dispose();
    _instagramController.dispose();
    _serviceDescriptionController.dispose();
    _totalAmountController.dispose();
    _discountController.dispose();
    _finalAmountController.dispose();
    _transactionIdController.dispose();
    _invoiceValueController.dispose();
    _advancePaymentController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
