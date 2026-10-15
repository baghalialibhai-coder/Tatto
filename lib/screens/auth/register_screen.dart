// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../core/enums/user_role.dart';
import '../admin/admin_dashboard_screen.dart';
import '../artist/artist_dashboard_screen.dart';
import '../customer/customer_home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Email
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

                // Mobile
                CustomTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  hint: 'Enter your mobile number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Mobile is required' : null,
                ),
                const SizedBox(height: 16),

                // Role Selection
                DropdownButtonFormField<UserRole>(
                  decoration: const InputDecoration(
                    labelText: 'Register as',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  value: _selectedRole,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 16),

                // Password
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
                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _register,
                  backgroundColor: Colors.blue,
                  icon: Icons.person_add,
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Login'),
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

  Future<void> _register() async {
    // Prevent multiple submissions
    if (_isLoading || _isNavigating) return;

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check if mounted before setting state
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authProvider.notifier);

      // Register the user
      final user = await auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobile: _mobileController.text.trim(),
        role: _selectedRole,
      );

      // Check mounted before any navigation
      if (!mounted) {
        _isLoading = false;
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully as ${user.role.label}!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Set navigating flag to prevent state updates
      _isNavigating = true;

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

      // Use pushReplacement to replace the register screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );

      // Reset loading state after navigation
      _isLoading = false;

    } catch (e) {
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    _isNavigating = true;
    super.dispose();
  }
}