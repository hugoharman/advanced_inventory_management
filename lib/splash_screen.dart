import 'dart:async';

import 'package:advanced_inventory_management/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'page/item_list_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _simulateLoading();
      }
    });

    _controller.forward();
    Future.delayed(Duration(milliseconds: 500), () {
      _textAnimationController.forward();
    });
  }


  void _simulateLoading() {
    const totalDuration = Duration(seconds: 1);
    const steps = 100;
    final stepDuration = totalDuration ~/ steps;

    Timer.periodic(stepDuration, (timer) {
      setState(() {
        _progressValue += 1.0 / steps;
      });

      if (_progressValue >= 1.0) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'assets/splash_animation.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                  repeat: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: AnimatedBuilder(
                animation: _textAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      "Advanced Inventory Management",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "A11.2021.13937",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}