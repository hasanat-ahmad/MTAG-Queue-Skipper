import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scanAnim = Tween<double>(
      begin: -60.0,
      end: 60.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.two_wheeler_rounded,
                    size: 70,
                    color: AppColors.backgroundLight,
                  ),
                  AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _scanAnim.value),
                        child: Container(
                          width: 100,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "MTag Queue Skipper",
              style: TextStyle(
                color: AppColors.backgroundLight,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
