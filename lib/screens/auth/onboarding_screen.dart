// lib/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/custom_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to The Temple of Tattooz',
      description: 'Chosen By Legends, Inked By Pros - Your trusted tattoo studio with 2 branches.',
      icon: Icons.brush,
      color: Colors.blue,
    ),
    OnboardingData(
      title: 'Easy Consent Form Management',
      description: 'Fill, sign and submit consent forms digitally in just a few clicks.',
      icon: Icons.assignment,
      color: Colors.purple,
    ),
    OnboardingData(
      title: 'Track Your Tattoo Journey',
      description: 'View your history, aftercare instructions, and appointment details anytime.',
      icon: Icons.timeline,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _buildPage(page);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData page) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: page.color),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
            onPressed: () {
              if (_currentPage == _pages.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
          ),
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}