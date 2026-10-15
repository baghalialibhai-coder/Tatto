// lib/screens/admin/service_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/service_model.dart';
import '../../core/enums/service_category.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ServiceManagementScreen extends ConsumerStatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  ConsumerState<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends ConsumerState<ServiceManagementScreen> {
  List<ServiceModel> services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      services = [
        ServiceModel(
          id: '1',
          category: ServiceCategory.tattoo,
          name: 'Small Tattoo',
          description: 'Small tattoo design',
          basePrice: 5000,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        ServiceModel(
          id: '2',
          category: ServiceCategory.tattoo,
          name: 'Medium Tattoo',
          description: 'Medium size tattoo design',
          basePrice: 10000,
          isActive: true, createdAt: DateTime.now(),
        ),
        ServiceModel(
          id: '3',
          category: ServiceCategory.piercing,
          name: 'Ear Piercing',
          description: 'Ear lobe piercing',
          basePrice: 1000,
          isActive: true, createdAt: DateTime.now(),
        ),
        ServiceModel(
          id: '4',
          category: ServiceCategory.temporary,
          name: 'Temporary Tattoo',
          description: 'Lasts 2-3 weeks',
          basePrice: 2000,
          isActive: false, createdAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServiceDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No services added yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: service.isActive ? Colors.green : Colors.red,
                child: Text(service.category.label[0]),
              ),
              title: Text(service.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${service.category.label}'),
                  Text('Price: ₹${service.basePrice}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: service.isActive,
                    onChanged: (value) {
                      setState(() {
                        services[index] = service.copyWith(isActive: value);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditServiceDialog(service, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteService(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        onSave: (service) {
          setState(() {
            services.add(service);
          });
        },
      ),
    );
  }

  void _showEditServiceDialog(ServiceModel service, int index) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        initialService: service,
        onSave: (updatedService) {
          setState(() {
            services[index] = updatedService;
          });
        },
      ),
    );
  }

  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                services.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service deleted'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ServiceDialog extends StatefulWidget {
  final ServiceModel? initialService;
  final Function(ServiceModel) onSave;

  const _ServiceDialog({this.initialService, required this.onSave});

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  ServiceCategory _selectedCategory = ServiceCategory.tattoo;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _nameController.text = widget.initialService!.name;
      _descriptionController.text = widget.initialService!.description;
      _priceController.text = widget.initialService!.basePrice.toString();
      _selectedCategory = widget.initialService!.category;
      _isActive = widget.initialService!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialService == null ? 'Add Service' : 'Edit Service'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Service Name',
              hint: 'Enter service name',
              icon: Icons.category,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceCategory>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              value: _selectedCategory,
              items: ServiceCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter service description',
              icon: Icons.description,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _priceController,
              label: 'Base Price (₹)',
              hint: 'Enter base price',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
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
          onPressed: _saveService,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveService() {
    if (!_formKey.currentState!.validate()) return;

    final service = ServiceModel(
      id: widget.initialService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      name: _nameController.text,
      description: _descriptionController.text,
      basePrice: double.tryParse(_priceController.text) ?? 0,
      isActive: _isActive, createdAt: DateTime.now(),
    );

    widget.onSave(service);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service saved successfully!'), backgroundColor: Colors.green),
    );
  }
}