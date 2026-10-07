import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';

/// Scrollable page frame for the login and sign-up screens: brand badge,
/// title, subtitle, then the form passed as [child].
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MTAG QUEUE SKIPPER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                    fontFamily: AppTextStyles.brandFontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.pageTitle),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.pageSubtitle),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
