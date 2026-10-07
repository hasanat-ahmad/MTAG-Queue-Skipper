import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';
import 'package:mtag_queue_skipper/features/home/widgets/active_token_card.dart';
import 'package:mtag_queue_skipper/features/home/widgets/home_service_tile.dart';
import 'package:mtag_queue_skipper/features/home/widgets/welcome_card.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

/// Hub after sign-in: greeting, the active token and the list of services.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final registration = context.watch<RegistrationController>();
    final token = registration.token;

    void open(String route) => Navigator.pushNamed(context, route);

    final services = [
      HomeService(
        title: 'Register Bike',
        subtitle: 'Add your motorcycle details',
        icon: Icons.electric_bike_outlined,
        iconBackground: AppColors.primarySoft,
        iconColor: AppColors.primary,
        onTap: () => open(AppRoutes.bikeRegistration),
      ),
      HomeService(
        title: 'My Token',
        subtitle: 'Track queue status & wait time',
        icon: Icons.confirmation_number_outlined,
        iconBackground: AppColors.accentSoft,
        iconColor: AppColors.accent,
        onTap: () => open(AppRoutes.tokenStatus),
      ),
      HomeService(
        title: 'Collect MTAG Card',
        subtitle: 'Verify face & receive your card',
        icon: Icons.credit_card_outlined,
        iconBackground: AppColors.primarySoft,
        iconColor: AppColors.primary,
        onTap: () => open(AppRoutes.cardIssuance),
        isReady: registration.isReadyToCollectCard,
      ),
      HomeService(
        title: 'Bike Details',
        subtitle: 'Plate, engine & registration info',
        icon: Icons.two_wheeler_outlined,
        iconBackground: AppColors.neutralSoft,
        iconColor: Colors.black87,
        onTap: () => open(AppRoutes.bikeDetails),
      ),
      HomeService(
        title: 'Profile',
        subtitle: 'Account & personal information',
        icon: Icons.person_outline_rounded,
        iconBackground: Colors.black,
        iconColor: Colors.white,
        onTap: () => open(AppRoutes.profile),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'MTAG',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: AppTextStyles.brandFontFamily,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            WelcomeCard(firstName: auth.user?.firstName ?? 'User'),
            if (token != null) ...[
              const SizedBox(height: 14),
              ActiveTokenCard(
                token: token,
                onTap: () => open(AppRoutes.tokenStatus),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            for (final service in services)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HomeServiceTile(service: service),
              ),
          ],
        ),
      ),
    );
  }
}
