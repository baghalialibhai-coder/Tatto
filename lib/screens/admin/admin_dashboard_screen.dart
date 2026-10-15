// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/recent_consent_card.dart';
import '../../widgets/navigation/side_menu.dart';
import '../../providers/consent_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/settings_screen.dart';
import 'branch_management_screen.dart';
import 'studio_setup_screen.dart';
import 'artist_management_screen.dart';
import 'reports_screen.dart';
import 'all_consent_forms_screen.dart';


class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // ✅ FIX: All lists should have the SAME number of items
  final List<Widget> _screens = const [
    AdminDashboardContent(),    // 0 - Dashboard
    StudioSetupScreen(),        // 1 - Studio Setup
    ArtistManagementScreen(),   // 2 - Artists
    BranchesScreen(),           // 3 - Branches
    AllConsentFormsScreen(),    // 4 - Consent Forms
    ReportsScreen(),            // 5 - Reports
    SettingsScreen(),           // 6 - Settings
  ];

  final List<String> _menuTitles = [
    'Dashboard',      // 0
    'Studio Setup',   // 1
    'Artists',        // 2
    'Branches',       // 3
    'Consent Forms',  // 4
    'Reports',        // 5
    'Settings',       // 6
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,      // 0
    Icons.store,          // 1
    Icons.people,         // 2
    Icons.location_city,  // 3
    Icons.assignment,     // 4
    Icons.receipt,        // 5
    Icons.settings,       // 6
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            selectedIndex: _selectedIndex,
            items: _menuTitles,
            icons: _menuIcons,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Dashboard Content - ✅ Fixed Type Cast Errors
// ============================================================

class AdminDashboardContent extends ConsumerWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // ✅ Stats data (real data from Firebase)
    final totalCustomers = consentState.forms.length;
    final totalRevenue = consentState.forms.fold(
      0.0,
          (sum, form) => sum + form.payment.finalAmount,
    );
    final todayAppointments = consentState.forms
        .where((form) => _isToday(form.appointment.date))
        .length;
    final activeArtists = consentState.forms
        .map((form) => form.artistName)
        .toSet()
        .length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, ${user?.name ?? 'Admin'}! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _getTodayDate(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards Grid
          Row(
            children: [
              _buildStatCard(
                title: 'Total Customers',
                value: totalCustomers.toString(),
                icon: Icons.people,
                color: Colors.blue,
                subtitle: _getPercentage(totalCustomers, 1000),
              ),
              _buildStatCard(
                title: 'Total Revenue',
                value: '₹${totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: _getPercentage(totalRevenue.toInt(), 50000),
              ),
              _buildStatCard(
                title: "Today's Appointments",
                value: todayAppointments.toString(),
                icon: Icons.calendar_today,
                color: Colors.orange,
                subtitle: '$todayAppointments appointments today',
              ),
              _buildStatCard(
                title: 'Active Artists',
                value: activeArtists.toString(),
                icon: Icons.brush,
                color: Colors.purple,
                subtitle: '$activeArtists artists working',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Consent Forms
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Consent Forms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to all forms
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Forms List
          Expanded(
            child: consentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : consentState.forms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: consentState.forms.length > 5
                  ? 5
                  : consentState.forms.length,
              itemBuilder: (context, index) {
                return RecentConsentCard(
                  consent: consentState.forms[index],
                  onTap: () {
                    // Navigate to form details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Helper Widgets
  // ============================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: StatsCard(
          title: title,
          value: value,
          icon: icon,
          color: color,
          subtitle: subtitle,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No consent forms yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating a new consent form',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getPercentage(int value, int total) {
    if (total == 0) return '0%';
    return '${((value / total) * 100).toStringAsFixed(0)}%';
  }
}