// lib/screens/shared/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../artist/artist_dashboard_screen.dart';
import '../customer/customer_home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// 🔍 Main Auth Check Method
  /// This method checks:
  /// 1. If user is authenticated
  /// 2. What role the user has (Admin, Artist, Customer)
  /// 3. Navigates to the appropriate dashboard
  Future<void> _checkAuthStatus() async {
    // ✅ Check if widget is still mounted before starting async work
    if (!mounted) return;

    // ⏳ Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // ✅ Check mounted after async work
    if (!mounted) return;

    // ✅ Prevent multiple navigation attempts
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // 📌 STEP 1: Read auth state from Riverpod
      final authState = ref.read(authProvider);

      // ✅ Check mounted again before navigation
      if (!mounted) {
        _isNavigating = false;
        return;
      }

      // 📌 STEP 2: Check if user is authenticated
      if (authState.isAuthenticated) {
        // ✅ User is logged in
        final user = authState.user;

        // 📌 STEP 3: Determine which dashboard to show based on role
        Widget nextScreen;

        switch (user?.role) {
          case UserRole.admin:
          // 👑 Admin Dashboard
            nextScreen = const AdminDashboardScreen();
            break;
          case UserRole.artist:
          // 🎨 Artist Dashboard
            nextScreen = const ArtistDashboardScreen();
            break;
          case UserRole.customer:
          // 👤 Customer Home
            nextScreen = const CustomerHomeScreen();
            break;
          default:
          // ❌ Unknown role - go to login
            nextScreen = const LoginScreen();
        }

        // 📌 STEP 4: Navigate to the appropriate dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => nextScreen),
            );
          }
        });
      } else {
        // ❌ User is NOT logged in - go to Login Screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      }
    } catch (e) {
      // ⚠️ Error occurred - go to Login Screen as fallback
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      }
    } finally {
      _isNavigating = false;
    }
  }

  @override
  void dispose() {
    _isNavigating = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.brush, size: 80, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'THE TEMPLE OF TATTOOZ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Chosen By Legends, Inked By Pros',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}