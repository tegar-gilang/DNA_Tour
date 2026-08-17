import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Connected Sacred Journey',
      'subtitle': 'Perform Umrah with complete peace of mind, knowing your group, tour leader, and loved ones are connected in real time.',
      'icon': '0', // index identifier for custom rendering
    },
    {
      'title': 'Real-Time Safety & SOS',
      'subtitle': 'Instant emergency assistance with one-touch medical, lost, or accident distress alerts transmitted with accurate GPS coordinates.',
      'icon': '1',
    },
    {
      'title': 'Complete Worship Companion',
      'subtitle': 'Access offline Umrah guides, authentic prayer collection with audio, live azan countdown, and digital tasbih anywhere in Makkah.',
      'icon': '2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/role_selection'),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  IconData iconData;
                  if (page['icon'] == '0') {
                    iconData = Icons.supervised_user_circle_rounded;
                  } else if (page['icon'] == '1') {
                    iconData = Icons.security_rounded;
                  } else {
                    iconData = Icons.auto_stories_rounded;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconData,
                            size: 70,
                            color: AppColors.primary,
                          ),
                        ).animate(key: ValueKey(index)).scale(duration: 500.ms, curve: Curves.easeOut),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ).animate(key: ValueKey('title_$index')).fadeIn(duration: 400.ms).moveY(begin: 10, end: 0),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ).animate(key: ValueKey('sub_$index')).fadeIn(delay: 150.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/role_selection');
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Continue'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
