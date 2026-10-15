// lib/screens/admin/payment_methods_screen.dart
import 'package:flutter/material.dart';
import '../../models/Payment_Method_Model.dart';
import '../../core/enums/payment_method.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethodModel> paymentMethods = [
    PaymentMethodModel(
      id: '1',
      name: 'Cash',
      type: PaymentMethod.cash,
      isActive: true,
      isDefault: true,
      displayOrder: 1,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '2',
      name: 'UPI',
      type: PaymentMethod.upi,
      isActive: true,
      isDefault: false,
      displayOrder: 2,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '3',
      name: 'GPay / UPI',
      type: PaymentMethod.gpay,
      isActive: true,
      isDefault: false,
      displayOrder: 3,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '4',
      name: 'Card',
      type: PaymentMethod.card,
      isActive: true,
      isDefault: false,
      displayOrder: 4,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '5',
      name: 'Net Banking',
      type: PaymentMethod.netBanking,
      isActive: false,
      isDefault: false,
      displayOrder: 5,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '6',
      name: 'Online',
      type: PaymentMethod.online,
      isActive: true,
      isDefault: false,
      displayOrder: 6,
      createdAt: DateTime.now(),
    ),
    PaymentMethodModel(
      id: '7',
      name: 'Other',
      type: PaymentMethod.other,
      isActive: true,
      isDefault: false,
      displayOrder: 7,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPaymentMethod,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enable/Disable payment methods. Only active methods will appear in consent form.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: method.isActive ? Colors.blue : Colors.grey.shade300,
                        child: Icon(
                          _getIcon(method.type),
                          color: method.isActive ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        method.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: method.isActive ? Colors.black : Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        method.isDefault ? 'Default' : '',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!method.isDefault)
                            IconButton(
                              icon: const Icon(Icons.star_border, size: 20),
                              onPressed: () => _setDefault(index),
                              tooltip: 'Set as default',
                            ),
                          Switch(
                            value: method.isActive,
                            onChanged: (value) {
                              setState(() {
                                paymentMethods[index] = method.copyWith(isActive: value);
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                      onTap: () => _editPaymentMethod(method, index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(PaymentMethod type) {
    switch (type) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.gpay:
        return Icons.payment;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.netBanking:
        return Icons.account_balance;
      case PaymentMethod.online:
        return Icons.language;
      default:
        return Icons.payment;
    }
  }

  void _addPaymentMethod() {
    // Show dialog to add new payment method
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add payment method feature coming soon!'),
      ),
    );
  }

  void _editPaymentMethod(PaymentMethodModel method, int index) {
    // Show dialog to edit payment method
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${method.name} feature coming soon!'),
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      // Reset all defaults
      paymentMethods = paymentMethods.map((m) {
        return m.copyWith(isDefault: false);
      }).toList();
      // Set selected as default
      paymentMethods[index] = paymentMethods[index].copyWith(isDefault: true);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default payment method updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}