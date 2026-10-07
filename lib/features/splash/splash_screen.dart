import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';
import 'package:mtag_queue_skipper/features/splash/widgets/scanning_bike_logo.dart';

/// Brand splash shown on launch before the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _displayDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    Future.delayed(_displayDuration, () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScanningBikeLogo(),
            SizedBox(height: 28),
            Text(
              'MTag Queue Skipper',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: AppTextStyles.brandFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
