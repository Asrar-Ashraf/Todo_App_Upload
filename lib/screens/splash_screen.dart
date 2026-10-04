import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    _progressController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TaskProvider>().load();
    });
    Future<void>.delayed(const Duration(seconds: 3), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    const Spacer(),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.08),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index == 2 ? 0 : 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: index == 1
                                        ? secondaryColor
                                        : primaryColor,
                                    size: 36,
                                  )
                                      .animate()
                                      .scale(
                                        delay: (index * 250).ms,
                                        duration: 550.ms,
                                        curve: Curves.easeOutBack,
                                      )
                                      .fadeIn(delay: (index * 250).ms),
                                  const SizedBox(width: 14),
                                  Container(
                                    width: 92,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'TaskFlow',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 38),
                    )
                        .animate()
                        .fadeIn(delay: 450.ms, duration: 700.ms)
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          delay: 450.ms,
                          duration: 700.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 8),
                    Text(
                      'Plan. Do. Done.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: subtitleTextColor,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 700.ms),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 3,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
