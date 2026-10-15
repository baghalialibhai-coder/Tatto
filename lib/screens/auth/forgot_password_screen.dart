import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/auth/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            if (_emailSent) ...[
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Password reset email sent!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your inbox for further instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Back to Login',
                onPressed: () => Navigator.pop(context),
              ),
            ] else ...[
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                icon: Icons.email,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Send Reset Link',
                isLoading: _isLoading,
                onPressed: _sendResetLink,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().resetPassword(_emailController.text);
      setState(() => _emailSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }
}