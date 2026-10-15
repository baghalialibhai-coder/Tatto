// lib/screens/artist/artist_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/payment_status.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/recent_consent_card.dart';
import '../../providers/consent_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/consent_form_screen.dart';
import 'artist_consent_form_screen.dart';
import 'artist_history_screen.dart';

class ArtistDashboardScreen extends ConsumerStatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  ConsumerState<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends ConsumerState<ArtistDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ArtistDashboardContent(),
    const ArtistConsentFormScreen(),
    const ArtistHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile
            },
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
          BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          BottomNavItem(icon: Icons.assignment, label: 'New Form'),
          BottomNavItem(icon: Icons.history, label: 'History'),
        ],
      ),
    );
  }
}

// ============================================================
// ArtistDashboardContent - The main dashboard widget (FIXED)
// ============================================================

class ArtistDashboardContent extends ConsumerWidget {
  const ArtistDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentState = ref.watch(consentFormProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get artist's forms
    final artistForms = consentState.forms
        .where((form) => form.artistId == user?.id)
        .toList();

    // Calculate stats
    final totalForms = artistForms.length;
    final totalRevenue = artistForms.fold(
      0.0,
          (sum, form) => sum + form.payment.finalAmount,
    );
    final pendingForms = artistForms
        .where((form) => form.payment.status == PaymentStatus.pending)
        .length;
    final completedForms = artistForms
        .where((form) => form.payment.status == PaymentStatus.paid)
        .length;
    final todayForms = artistForms
        .where((form) => form.appointment.date == _getTodayDate())
        .length;

    // ✅ FIX: Use a SingleChildScrollView to make content scrollable
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.blue],
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
                    user?.name[0].toUpperCase() ?? 'A',
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
                        user?.name ?? 'Artist',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Forms: $totalForms',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Today: $todayForms',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid - ✅ Fixed: Using SizedBox with height
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150, // ✅ Fixed height for grid
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatsCard(
                  title: 'Total Forms',
                  value: totalForms.toString(),
                  icon: Icons.assignment,
                  color: Colors.blue,
                  subtitle: 'All time',
                ),
                _buildStatsCard(
                  title: 'Revenue',
                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  subtitle: 'Total earned',
                ),
                _buildStatsCard(
                  title: 'Completed',
                  value: completedForms.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green.shade700,
                  subtitle: 'Paid forms',
                ),
                _buildStatsCard(
                  title: 'Pending',
                  value: pendingForms.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                  subtitle: 'Waiting',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Forms - ✅ Fixed: Using SizedBox with limited height
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Forms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all forms
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ Fixed: Using SizedBox with fixed height for list
          if (artistForms.isEmpty)
            Center(
              heightFactor: 2, // ✅ Reduce height for empty state
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
                    'No forms yet',
                    style: TextStyle(
                      fontSize: 16,
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
            )
          else
            SizedBox(
              height: 250, // ✅ Fixed height for recent forms
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: artistForms.length > 5 ? 5 : artistForms.length,
                itemBuilder: (context, index) {
                  return RecentConsentCard(
                    consent: artistForms[index],
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

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
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
                child: Icon(icon, size: 20, color: color),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
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

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }
}
