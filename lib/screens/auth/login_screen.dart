// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../admin/admin_dashboard_screen.dart';
import '../artist/artist_dashboard_screen.dart';
import '../customer/customer_home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isNavigating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for any changes
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'THE TEMPLE OF TATTOOZ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Chosen By Legends, Inked By Pros',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Error Message
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Login Button
                CustomButton(
                  text: 'Login',
                  isLoading: _isLoading || authState.isLoading,
                  onPressed: _login,
                  backgroundColor: Colors.blue,
                  icon: Icons.login,
                ),
                const SizedBox(height: 16),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Try to load asset logo, fallback to icon if not available
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.brush,
          size: 50,
          color: Colors.blue,
        ),
      ),
    );
  }

  Future<void> _login() async {
    // ✅ Prevent multiple submissions
    if (_isLoading || _isNavigating) return;

    // ✅ Validate fields
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Set loading state
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authProvider.notifier);

      // ✅ Perform login
      final user = await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ Check if widget is still mounted
      if (!mounted) {
        _isLoading = false;
        return;
      }

      // ✅ Navigate based on user role
      Widget nextScreen;
      switch (user.role) {
        case UserRole.admin:
          nextScreen = const AdminDashboardScreen();
          break;
        case UserRole.artist:
          nextScreen = const ArtistDashboardScreen();
          break;
        case UserRole.customer:
          nextScreen = const CustomerHomeScreen();
          break;
      }

      // ✅ Set navigating flag
      _isNavigating = true;

      // ✅ Navigate to the appropriate dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );

      // ✅ Reset loading state (after navigation)
      _isLoading = false;

    } catch (e) {
      // ✅ Handle error - only if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}