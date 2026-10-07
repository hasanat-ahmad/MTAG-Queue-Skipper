import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';
import 'package:mtag_queue_skipper/features/splash/splash_controller.dart';
import 'package:mtag_queue_skipper/features/splash/widgets/scanning_bike_logo.dart';
import 'package:provider/provider.dart';

/// Brand splash shown on launch. Riders who are still signed in go straight
/// home; everyone else goes to the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _leaveSplash();
  }

  Future<void> _leaveSplash() async {
    final controller = SplashController(
      auth: context.read(),
      registration: context.read(),
    );
    final route = await controller.resolveStartRoute();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
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
