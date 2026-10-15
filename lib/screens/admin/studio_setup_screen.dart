// lib/screens/admin/studio_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/studio_model.dart';
import '../../models/branch_model.dart';
import '../../services/database/firestore_service.dart';
import '../../providers/auth_provider.dart';

class StudioSetupScreen extends ConsumerStatefulWidget {
  const StudioSetupScreen({super.key});

  @override
  ConsumerState<StudioSetupScreen> createState() => _StudioSetupScreenState();
}

class _StudioSetupScreenState extends ConsumerState<StudioSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _currencyController = TextEditingController(text: 'INR');
  final _taxController = TextEditingController(text: '18');
  final _logoController = TextEditingController();

  bool _isLoading = false;
  bool _isExistingStudio = false;
  String? _studioId;

  // Branches
  List<BranchModel> _branches = [];
  final _branchNameController = TextEditingController();
  final _branchAddressController = TextEditingController();
  final _branchPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudioData();
  }

  // ============================================================
  // Load Existing Studio Data
  // ============================================================

  Future<void> _loadStudioData() async {
    setState(() => _isLoading = true);

    try {
      final firestore = FirestoreService();
      final studio = await firestore.getStudio();

      if (studio != null) {
        _isExistingStudio = true;
        _studioId = studio.id;

        // Fill form with existing data
        _nameController.text = studio.name;
        _addressController.text = studio.address;
        _phoneController.text = studio.phone;
        _emailController.text = studio.email;
        _gstController.text = studio.gstNumber ?? '';
        _currencyController.text = studio.currency;
        _taxController.text = studio.taxRate.toString();
        _branches = studio.branches;

        // ✅ Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Studio data loaded successfully!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading studio: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // Build Method
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isExistingStudio ? 'Edit Studio' : 'Studio Setup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isExistingStudio)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteStudio,
              tooltip: 'Delete Studio',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Studio Information
                _buildSection('🏢 Studio Information'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nameController,
                  label: 'Studio Name',
                  hint: 'Enter studio name',
                  icon: Icons.store,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Studio name is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter full address',
                  icon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Address is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  icon: Icons.phone,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _gstController,
                  label: 'GST / Tax Info',
                  hint: 'Enter GST number',
                  icon: Icons.receipt,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _logoController,
                  label: 'Logo URL',
                  hint: 'Enter logo URL (optional)',
                  icon: Icons.image,
                ),
                const SizedBox(height: 24),

                // Payment Settings
                _buildSection('💰 Payment Settings'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _currencyController,
                  label: 'Currency',
                  hint: 'INR, USD, etc.',
                  icon: Icons.currency_exchange,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _taxController,
                  label: 'Tax Rate (%)',
                  hint: 'Enter tax percentage',
                  icon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Branches
                _buildSection('🏪 Branches'),
                const SizedBox(height: 16),

                // Branch List
                if (_branches.isNotEmpty) ...[
                  ..._branches.map((branch) => _buildBranchCard(branch)),
                  const SizedBox(height: 12),
                ],

                // Add Branch Button
                _buildAddBranchButton(),

                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: _isExistingStudio
                      ? 'Update Studio Settings'
                      : 'Save Studio Settings',
                  isLoading: _isLoading,
                  onPressed: _saveStudio,
                  backgroundColor: Colors.blue,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI Helper Methods
  // ============================================================

  Widget _buildSection(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildBranchCard(BranchModel branch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.store, color: Colors.blue),
        title: Text(branch.name),
        subtitle: Text(branch.address),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _editBranch(branch),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteBranch(branch.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBranchButton() {
    return OutlinedButton.icon(
      onPressed: _showAddBranchDialog,
      icon: const Icon(Icons.add, color: Colors.blue),
      label: const Text('Add Branch'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ============================================================
  // Branch CRUD Operations
  // ============================================================

  void _showAddBranchDialog() {
    _branchNameController.clear();
    _branchAddressController.clear();
    _branchPhoneController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _branchNameController,
              label: 'Branch Name',
              hint: 'Enter branch name',
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _branchAddressController,
              label: 'Branch Address',
              hint: 'Enter branch address',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _branchPhoneController,
              label: 'Branch Phone',
              hint: 'Enter branch phone',
              icon: Icons.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_branchNameController.text.isNotEmpty &&
                  _branchAddressController.text.isNotEmpty) {
                setState(() {
                  _branches.add(
                    BranchModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _branchNameController.text,
                      address: _branchAddressController.text,
                      phone: _branchPhoneController.text.isNotEmpty
                          ? _branchPhoneController.text
                          : '',
                      isActive: true,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Branch added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editBranch(BranchModel branch) {
    _branchNameController.text = branch.name;
    _branchAddressController.text = branch.address;
    _branchPhoneController.text = branch.phone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _branchNameController,
              label: 'Branch Name',
              hint: 'Enter branch name',
              icon: Icons.store,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _branchAddressController,
              label: 'Branch Address',
              hint: 'Enter branch address',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _branchPhoneController,
              label: 'Branch Phone',
              hint: 'Enter branch phone',
              icon: Icons.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final index = _branches.indexWhere((b) => b.id == branch.id);
              if (index != -1) {
                setState(() {
                  _branches[index] = branch.copyWith(
                    name: _branchNameController.text,
                    address: _branchAddressController.text,
                    phone: _branchPhoneController.text,
                  );
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Branch updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBranch(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: const Text('Are you sure you want to delete this branch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _branches.removeWhere((b) => b.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Branch deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Save to Firebase
  // ============================================================

  Future<void> _saveStudio() async {
    // ✅ Validate form
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validate branches
    if (_branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one branch'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // ✅ Create Studio Model
      final studio = StudioModel(
        id: _studioId ?? '',
        name: _nameController.text.trim(),
        logoUrl: _logoController.text.trim().isNotEmpty
            ? _logoController.text.trim()
            : '',
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gstNumber: _gstController.text.trim().isNotEmpty
            ? _gstController.text.trim()
            : null,
        currency: _currencyController.text.trim(),
        taxRate: double.tryParse(_taxController.text) ?? 18.0,
        branches: _branches,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // ✅ Save to Firebase
      final firestore = FirestoreService();
      String? studioId;

      if (_isExistingStudio && _studioId != null) {
        // ✅ Update existing studio
        await firestore.updateStudio(studio);
        studioId = _studioId;
      } else {
        // ✅ Create new studio
        studioId = await firestore.saveStudio(studio);
      }

      // ✅ Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isExistingStudio
                  ? 'Studio updated successfully! 🎉'
                  : 'Studio created successfully! 🎉',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Update state
        setState(() {
          _isExistingStudio = true;
          _studioId = studioId;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving studio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // Delete Studio
  // ============================================================

  Future<void> _deleteStudio() async {
    if (_studioId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Studio'),
        content: const Text(
          'Are you sure you want to delete this studio? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                final firestore = FirestoreService();
                await firestore.deleteStudio(_studioId!);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Studio deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Reset form
                  _nameController.clear();
                  _addressController.clear();
                  _phoneController.clear();
                  _emailController.clear();
                  _gstController.clear();
                  _branches.clear();
                  setState(() {
                    _isExistingStudio = false;
                    _studioId = null;
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting studio: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _currencyController.dispose();
    _taxController.dispose();
    _logoController.dispose();
    _branchNameController.dispose();
    _branchAddressController.dispose();
    _branchPhoneController.dispose();
    super.dispose();
  }
}