import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../core/enums/user_role.dart';
import '../screens/auth/login_screen.dart';

class RouteGuard extends ConsumerWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RouteGuard({
    super.key,
    required this.child,
    this.allowedRoles = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    if (allowedRoles.isNotEmpty && !allowedRoles.contains(authState.user?.role)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permission to access this page',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}