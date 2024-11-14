import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:maroro/Auth/login.dart';
import 'package:maroro/main.dart';

class AppWalkthrough extends StatefulWidget {
  @override
  _AppWalkthroughState createState() => _AppWalkthroughState();
}

class _AppWalkthroughState extends State<AppWalkthrough> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_currentPage < 4) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
        );
        setState(() {});
      } else {
        _currentPage = 0;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 32, 32, 32),
              Color.fromARGB(255, 242, 255, 231)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _autoSlideTimer?.cancel();
                    _startAutoSlide();
                  },
                  children: [
                    _WalkthroughPage(
                      title: 'Welcome to CelebrEase',
                      description:
                          'Discover and book the perfect event services for your special occasions.',
                      animation: Lottie.asset(
                        'assets/lottie/welcom.json',
                      ),
                    ),
                    _WalkthroughPage(
                      title: 'Browse Vendors',
                      description:
                          'Explore a curated selection of event professionals, from photographers to caterers.',
                      animation: Lottie.asset(
                        'assets/lottie/browse.json',
                      ),
                    ),
                    _WalkthroughPage(
                      title: 'Customize Your Event',
                      description:
                          'Create your dream event by easily booking and managing all your vendors in one place.',
                      animation: Lottie.asset(
                        'assets/lottie/customize.json',
                      ),
                    ),
                    _WalkthroughPage(
                      title: 'Magical Moments',
                      description:
                          'Let CelebrEase take care of the details so you can focus on making lasting memories.',
                      animation: Lottie.asset(
                        'assets/lottie/anime.json',
                      ),
                    ),
                    _WalkthroughPage(
                      title: 'Get Started',
                      description:
                          'Start planning your unforgettable event today. Sign In to CelebrEase!',
                      animation: Lottie.asset(
                        'assets/lottie/anime.json',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogIn(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1F1F1F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkthroughPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget animation;

  const _WalkthroughPage({
    Key? key,
    required this.title,
    required this.description,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.wand,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: animation,
            ),
          ),
        ),
      ],
    );
  }
}
