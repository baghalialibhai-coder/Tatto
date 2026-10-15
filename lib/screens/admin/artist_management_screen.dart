// lib/screens/admin/artist_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/artist_provider.dart';
import '../../models/artist_model.dart';
import '../../core/enums/artist_payment_type.dart';
import '../../core/enums/user_role.dart';
import '../../widgets/common/custom_button.dart';

class ArtistManagementScreen extends ConsumerStatefulWidget {
  const ArtistManagementScreen({super.key});

  @override
  ConsumerState<ArtistManagementScreen> createState() => _ArtistManagementScreenState();
}

class _ArtistManagementScreenState extends ConsumerState<ArtistManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load artists when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(artistProvider.notifier).loadArtists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final artistState = ref.watch(artistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddArtistDialog,
          ),
        ],
      ),
      body: artistState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : artistState.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              artistState.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(artistProvider.notifier).loadArtists();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : artistState.artists.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No artists added yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add an artist',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: artistState.artists.length,
        itemBuilder: (context, index) {
          final artist = artistState.artists[index];
          return _buildArtistCard(artist);
        },
      ),
    );
  }

  Widget _buildArtistCard(ArtistModel artist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: artist.isActive ? Colors.green : Colors.red,
          child: Text(
            artist.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          artist.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment: ${artist.paymentType.label}'),
            // Text(
            //   artist.getPaymentDescription(),
            //   style: const TextStyle(fontSize: 12),
            // ),
            if (artist.specialty != null)
              Text(
                'Specialty: ${artist.specialty}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: artist.isActive,
              onChanged: (value) {
                final updated = artist.copyWith(isActive: value);
                ref.read(artistProvider.notifier).updateArtist(updated);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _showEditArtistDialog(artist),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteArtist(artist.id),
            ),
          ],
        ),
        onTap: () => _showArtistDetails(artist),
      ),
    );
  }

  void _showAddArtistDialog() {
    showDialog(
      context: context,
      builder: (context) => _ArtistDialog(
        onSave: (artist) {
          ref.read(artistProvider.notifier).addArtist(artist);
        },
      ),
    );
  }

  void _showEditArtistDialog(ArtistModel artist) {
    showDialog(
      context: context,
      builder: (context) => _ArtistDialog(
        initialArtist: artist,
        onSave: (updatedArtist) {
          ref.read(artistProvider.notifier).updateArtist(updatedArtist);
        },
      ),
    );
  }

  void _deleteArtist(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artist'),
        content: const Text('Are you sure you want to delete this artist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(artistProvider.notifier).deleteArtist(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Artist deleted successfully'),
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

  void _showArtistDetails(ArtistModel artist) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      artist.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: artist.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      artist.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            _buildDetail('Email', artist.email ?? 'N/A'),
            _buildDetail('Phone', artist.phone ?? 'N/A'),
            _buildDetail('Payment Type', artist.paymentType.label),
           // _buildDetail('Payment Details', artist.getPaymentDescription()),
            _buildDetail('Specialty', artist.specialty ?? 'General'),
            _buildDetail('Joining Date', artist.joiningDate.toString().split(' ')[0]),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============================================================================
// Artist Dialog for Add/Edit
// ============================================================================

class _ArtistDialog extends StatefulWidget {
  final ArtistModel? initialArtist;
  final Function(ArtistModel) onSave;

  const _ArtistDialog({this.initialArtist, required this.onSave});

  @override
  State<_ArtistDialog> createState() => _ArtistDialogState();
}

class _ArtistDialogState extends State<_ArtistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  ArtistPaymentType _paymentType = ArtistPaymentType.percentage;
  final _fixedSalaryController = TextEditingController();
  final _percentageController = TextEditingController();
  final _fixedAmountController = TextEditingController();
  final _profitShareController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialArtist != null) {
      _nameController.text = widget.initialArtist!.name;
      _emailController.text = widget.initialArtist!.email ?? '';
      _phoneController.text = widget.initialArtist!.phone ?? '';
      _specialtyController.text = widget.initialArtist!.specialty ?? '';
      _bioController.text = widget.initialArtist!.bio ?? '';
      _paymentType = widget.initialArtist!.paymentType;
      _fixedSalaryController.text = widget.initialArtist!.fixedSalary?.toString() ?? '';
      _percentageController.text = widget.initialArtist!.percentage?.toString() ?? '';
      _fixedAmountController.text = widget.initialArtist!.fixedAmount?.toString() ?? '';
      _profitShareController.text = widget.initialArtist!.profitSharePercentage?.toString() ?? '';
      _isActive = widget.initialArtist!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialArtist == null ? 'Add Artist' : 'Edit Artist'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Payment Type
              DropdownButtonFormField<ArtistPaymentType>(
                decoration: const InputDecoration(
                  labelText: 'Payment Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                value: _paymentType,
                items: ArtistPaymentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentType = value);
                },
              ),
              const SizedBox(height: 12),

              // Dynamic Payment Fields
              if (_paymentType == ArtistPaymentType.fixed) ...[
                TextFormField(
                  controller: _fixedSalaryController,
                  decoration: const InputDecoration(
                    labelText: 'Fixed Salary (₹) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Salary is required' : null,
                ),
              ] else if (_paymentType == ArtistPaymentType.percentage) ...[
                TextFormField(
                  controller: _percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Commission Percentage (%) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Percentage is required' : null,
                ),
              ] else if (_paymentType == ArtistPaymentType.fixedPlusPercentage) ...[
                TextFormField(
                  controller: _fixedAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Fixed Amount (₹) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Fixed amount is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _percentageController,
                  decoration: const InputDecoration(
                    labelText: 'Commission Percentage (%) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Percentage is required' : null,
                ),
              ] else if (_paymentType == ArtistPaymentType.profitShare) ...[
                TextFormField(
                  controller: _profitShareController,
                  decoration: const InputDecoration(
                    labelText: 'Profit Share Percentage (%) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Profit share is required' : null,
                ),
              ],
              const SizedBox(height: 12),

              // Specialty
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  hintText: 'e.g., Realistic, Tribal, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.brush),
                ),
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Short description about the artist',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Active
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Enable this artist for appointments'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveArtist,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveArtist() {
    if (!_formKey.currentState!.validate()) return;

    double? fixedSalary;
    double? percentage;
    double? fixedAmount;
    double? profitShare;

    switch (_paymentType) {
      case ArtistPaymentType.fixed:
        fixedSalary = double.tryParse(_fixedSalaryController.text);
        break;
      case ArtistPaymentType.percentage:
        percentage = double.tryParse(_percentageController.text);
        break;
      case ArtistPaymentType.fixedPlusPercentage:
        fixedAmount = double.tryParse(_fixedAmountController.text);
        percentage = double.tryParse(_percentageController.text);
        break;
      case ArtistPaymentType.profitShare:
        profitShare = double.tryParse(_profitShareController.text);
        break;
    }

    final artist = ArtistModel(
      id: widget.initialArtist?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      role: UserRole.artist,
      paymentType: _paymentType,
      fixedSalary: fixedSalary,
      percentage: percentage,
      fixedAmount: fixedAmount,
      profitSharePercentage: profitShare,
      specialty: _specialtyController.text.isNotEmpty ? _specialtyController.text : null,
      bio: _bioController.text.isNotEmpty ? _bioController.text : null,
      isActive: _isActive,
      joiningDate: widget.initialArtist?.joiningDate ?? DateTime.now(),
      createdAt: widget.initialArtist?.createdAt ?? DateTime.now(),
    );

    widget.onSave(artist);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artist saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}