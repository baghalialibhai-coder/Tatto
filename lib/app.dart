// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tattoo/screens/shared/consent_form_screen.dart';
import 'core/enums/user_role.dart';
import 'firebase/firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/artist/artist_dashboard_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider); // ← Add theme mode

    return MaterialApp(
      title: 'The Temple of Tattooz',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // ← Add theme mode
      home: authState.isLoading
          ? const SplashScreen()
          : authState.isAuthenticated
          ? _getHomeScreen(authState.user?.role)
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/artist/dashboard': (context) => const ArtistDashboardScreen(),
        '/customer/home': (context) => const CustomerHomeScreen(),
        '/customer/new-form': (context) => const ConsentFormScreen(),
        '/artist/new-form': (context) => const ConsentFormScreen(),
      },
    );
  }

  Widget _getHomeScreen(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.artist:
        return const ArtistDashboardScreen();
      case UserRole.customer:
        return const CustomerHomeScreen();
      default:
        return const LoginScreen();
    }
  }
}