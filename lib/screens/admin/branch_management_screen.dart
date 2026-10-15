// lib/screens/admin/branches_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/branch_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/database/firestore_service.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  List<BranchModel> _branches = [];
  bool _isLoading = true;
  String? _error;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    try {
      final firestore = FirestoreService();
      _branches = await firestore.getBranches();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBranchDialog,
            tooltip: 'Add Branch',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBranches,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: _loadBranches,
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      )
          : _branches.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Branches Added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first branch to get started',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add Branch',
              onPressed: _showAddBranchDialog,
              backgroundColor: Colors.blue,
              icon: Icons.add,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _branches.length,
        itemBuilder: (context, index) {
          final branch = _branches[index];
          return _buildBranchCard(branch);
        },
      ),
    );
  }

  Widget _buildBranchCard(BranchModel branch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: branch.isActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.store,
                    color: branch.isActive ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        branch.address,
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
                    color: branch.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    branch.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  branch.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                if (branch.email != null) ...[
                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    branch.email!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            if (branch.managerName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Manager: ${branch.managerName}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (branch.managerPhone != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${branch.managerPhone})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: branch.isActive,
                  onChanged: (value) {
                    _toggleBranchStatus(branch.id, value);
                  },
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditBranchDialog(branch),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBranch(branch.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBranchDialog() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _managerNameController.clear();
    _managerPhoneController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Branch Name',
                hint: 'Enter branch name',
                icon: Icons.store,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter branch address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter branch phone',
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter branch email (optional)',
                icon: Icons.email,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _managerNameController,
                label: 'Manager Name',
                hint: 'Enter manager name (optional)',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _managerPhoneController,
                label: 'Manager Phone',
                hint: 'Enter manager phone (optional)',
                icon: Icons.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _saveBranch,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBranchDialog(BranchModel branch) {
    _nameController.text = branch.name;
    _addressController.text = branch.address;
    _phoneController.text = branch.phone;
    _emailController.text = branch.email ?? '';
    _managerNameController.text = branch.managerName ?? '';
    _managerPhoneController.text = branch.managerPhone ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Branch Name',
                hint: 'Enter branch name',
                icon: Icons.store,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter branch address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter branch phone',
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter branch email (optional)',
                icon: Icons.email,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _managerNameController,
                label: 'Manager Name',
                hint: 'Enter manager name (optional)',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _managerPhoneController,
                label: 'Manager Phone',
                hint: 'Enter manager phone (optional)',
                icon: Icons.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _updateBranch(branch.id),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBranch() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and address are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final branch = BranchModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      managerName: _managerNameController.text.trim().isNotEmpty ? _managerNameController.text.trim() : null,
      managerPhone: _managerPhoneController.text.trim().isNotEmpty ? _managerPhoneController.text.trim() : null,
      isActive: true,
      createdAt: DateTime.now(),
    );

    try {
      final firestore = FirestoreService();
      await firestore.saveBranch(branch);
      setState(() {
        _branches.add(branch);
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Branch added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateBranch(String id) async {
    final index = _branches.indexWhere((b) => b.id == id);
    if (index == -1) return;

    final updatedBranch = _branches[index].copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      managerName: _managerNameController.text.trim().isNotEmpty ? _managerNameController.text.trim() : null,
      managerPhone: _managerPhoneController.text.trim().isNotEmpty ? _managerPhoneController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    try {
      final firestore = FirestoreService();
      await firestore.updateBranch(updatedBranch);
      setState(() {
        _branches[index] = updatedBranch;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Branch updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleBranchStatus(String id, bool value) async {
    try {
      final firestore = FirestoreService();
      final index = _branches.indexWhere((b) => b.id == id);
      if (index == -1) return;

      final updatedBranch = _branches[index].copyWith(isActive: value);
      await firestore.updateBranch(updatedBranch);
      setState(() {
        _branches[index] = updatedBranch;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBranch(String id) async {
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
            onPressed: () async {
              try {
                final firestore = FirestoreService();
                await firestore.deleteBranch(id);
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
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}