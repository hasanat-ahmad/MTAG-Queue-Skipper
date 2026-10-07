import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/features/bike_details/widgets/bike_details_cards.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

/// Read-only view of the registered bike and its owner.
class BikeDetailsScreen extends StatelessWidget {
  const BikeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bike = context.watch<RegistrationController>().bikeDetails;
    final owner = context.watch<AuthController>().user;

    if (bike == null) {
      return MtagScaffold(
        title: 'Bike Details',
        body: MtagEmptyState(
          icon: Icons.two_wheeler_outlined,
          iconColor: AppColors.primary,
          iconBackground: AppColors.primarySoft,
          title: 'Nothing here yet',
          message: 'Register your bike and your details will show up.',
          actionLabel: 'Register bike',
          onAction: () =>
              Navigator.pushNamed(context, AppRoutes.bikeRegistration),
        ),
      );
    }

    return MtagScaffold(
      title: 'Bike Details',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          BikeSummaryHeader(
            ownerName: owner?.hasName == true ? owner!.name : '—',
            plateNumber: bike.plateNumber,
          ),
          const SizedBox(height: 14),
          OwnerDetailsCard(owner: owner),
          const SizedBox(height: 12),
          MotorcycleCard(bike: bike),
        ],
      ),
    );
  }
}
