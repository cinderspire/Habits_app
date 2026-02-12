import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Build Habits',
      subtitle:
          'Start small and build powerful daily habits that stick. Your journey to a better you begins here.',
    ),
    _OnboardingPage(
      icon: Icons.local_fire_department_rounded,
      title: 'Track Streaks',
      subtitle:
          'Keep your streaks alive and stay motivated. Watch your consistency grow day after day.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Achieve Goals',
      subtitle:
          'Turn your habits into achievements. Celebrate milestones and unlock your full potential.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryOrange
                          : AppColors.backgroundLightElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange.withValues(alpha: 0.15),
                  AppColors.primaryYellow.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
