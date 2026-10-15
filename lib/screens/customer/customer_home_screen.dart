// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/service_category.dart';
import '../../models/consent_form_model.dart';
import '../../models/user_model.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/consent_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/enums/payment_status.dart';
import '../shared/consent_form_screen.dart';
import 'customer_appointments_screen.dart';
import 'customer_history_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_consent_form_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeContent(),
    const CustomerAppointmentsScreen(),
    const CustomerHistoryScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Temple of Tattooz'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          // ✅ Quick New Form Button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToNewForm();
            },
            tooltip: 'New Consent Form',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavItem(icon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.calendar_today, label: 'Appointments'),
          BottomNavItem(icon: Icons.history, label: 'History'),
          BottomNavItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
      // ✅ Floating Action Button for New Form
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewForm,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'New Consent Form',
      ),
    );
  }

  void _navigateToNewForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerConsentFormScreen(),
      ),
    );
  }
}

// ============================================================
// CustomerHomeContent - The main home screen widget
// ============================================================

class CustomerHomeContent extends ConsumerWidget {
  const CustomerHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get customer's forms
    final customerForms = consentState.forms
        .where((form) => form.customer.id == user?.id)
        .toList();

    // Calculate stats
    final totalForms = customerForms.length;
    final totalSpent = customerForms.fold(
      0.0,
          (sum, form) => sum + form.payment.finalAmount,
    );
    final completedForms = customerForms
        .where((form) => form.payment.status == PaymentStatus.paid)
        .length;
    final pendingForms = customerForms
        .where((form) => form.payment.status == PaymentStatus.pending)
        .length;

    // Get upcoming appointments
    final upcomingForms = customerForms
        .where((form) => _isUpcoming(form))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Welcome Section
          _buildWelcomeSection(user, totalForms),

          const SizedBox(height: 24),

          // ✅ Quick Action Buttons
          _buildQuickActions(context),

          const SizedBox(height: 24),

          // ✅ Stats Grid
          _buildStatsSection(
            totalForms: totalForms,
            totalSpent: totalSpent,
            completedForms: completedForms,
            pendingForms: pendingForms,
          ),

          const SizedBox(height: 24),

          // ✅ Upcoming Appointments
          _buildUpcomingSection(context, upcomingForms),
        ],
      ),
    );
  }

  // ============================================================
  // Welcome Section
  // ============================================================

  Widget _buildWelcomeSection(UserModel? user, int totalForms) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color.fromARGB(255, 21, 101, 192)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              user?.name[0].toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  user?.name ?? 'Customer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$totalForms appointments completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // ✅ Quick Stats Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🎯 $totalForms',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Quick Actions
  // ============================================================

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: '📝 Book Now',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerConsentFormScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue,
            icon: Icons.add,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: '📅 Appointments',
            onPressed: () {
              // Navigate to appointments tab
              final homeState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
              if (homeState != null) {
                homeState.setState(() {
                  homeState._selectedIndex = 1;
                });
              }
            },
            backgroundColor: Colors.green,
            icon: Icons.calendar_today,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Stats Section
  // ============================================================

  Widget _buildStatsSection({
    required int totalForms,
    required double totalSpent,
    required int completedForms,
    required int pendingForms,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Your Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatsCard(
              title: 'Total Visits',
              value: totalForms.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            _buildStatsCard(
              title: 'Total Spent',
              value: '₹${totalSpent.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _buildStatsCard(
              title: 'Completed',
              value: completedForms.toString(),
              icon: Icons.check_circle,
              color: Colors.green.shade700,
            ),
            _buildStatsCard(
              title: 'Pending',
              value: pendingForms.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Upcoming Appointments Section
  // ============================================================

  Widget _buildUpcomingSection(BuildContext context, List<ConsentFormModel> upcomingForms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📅 Upcoming Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to appointments tab
                final homeState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 1;
                  });
                }
              },
              child: const Text('View All →'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (upcomingForms.isEmpty)
          _buildEmptyUpcomingState(context)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingForms.length > 3 ? 3 : upcomingForms.length,
            itemBuilder: (context, index) {
              final form = upcomingForms[index];
              return _buildUpcomingCard(form);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyUpcomingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: '📝 Book Your First Session',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerConsentFormScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue,
            height: 40,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(ConsentFormModel form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.event,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(
          form.service.category.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${form.appointment.date.toString().split(' ')[0]} at ${form.appointment.time}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Upcoming',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          // Show appointment details
        },
      ),
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  bool _isUpcoming(ConsentFormModel form) {
    try {
      final dateStr = form.appointment.date.toString().split(' ')[0];
      final dateParts = dateStr.split('-');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        final formDate = DateTime(year, month, day);
        final now = DateTime.now();
        return formDate.isAfter(now) || formDate.isAtSameMomentAs(now);
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}