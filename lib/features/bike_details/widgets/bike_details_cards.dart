import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';

/// Green banner with the owner's name and the plate number.
class BikeSummaryHeader extends StatelessWidget {
  const BikeSummaryHeader({
    super.key,
    required this.ownerName,
    required this.plateNumber,
  });

  final String ownerName;
  final String plateNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  plateNumber,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Owner name, phone and CNIC; shows "—" for anything not provided.
class OwnerDetailsCard extends StatelessWidget {
  const OwnerDetailsCard({super.key, required this.owner});

  final UserProfile? owner;

  static String _orDash(String? value) =>
      value != null && value.trim().isNotEmpty ? value : '—';

  @override
  Widget build(BuildContext context) {
    return MtagSectionCard(
      title: 'Owner',
      child: Column(
        children: [
          MtagInfoTile(
            icon: Icons.person_outline,
            label: 'Name',
            value: _orDash(owner?.name),
          ),
          MtagInfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _orDash(owner?.phoneNumber),
          ),
          MtagInfoTile(
            icon: Icons.badge_outlined,
            label: 'CNIC',
            value: _orDash(owner?.cnic),
          ),
        ],
      ),
    );
  }
}

/// Brand, colour and year (when known) plus plate, engine and chassis.
class MotorcycleCard extends StatelessWidget {
  const MotorcycleCard({super.key, required this.bike});

  final BikeDetails bike;

  @override
  Widget build(BuildContext context) {
    return MtagSectionCard(
      title: 'Motorcycle',
      child: Column(
        children: [
          if (bike.brand.trim().isNotEmpty)
            MtagInfoTile(
              icon: Icons.branding_watermark_outlined,
              label: 'Brand',
              value: bike.brand,
            ),
          if (bike.color.trim().isNotEmpty)
            MtagInfoTile(
              icon: Icons.palette_outlined,
              label: 'Color',
              value: bike.color,
            ),
          if (bike.year.trim().isNotEmpty)
            MtagInfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Year',
              value: bike.year,
            ),
          MtagInfoTile(
            icon: Icons.pin_outlined,
            label: 'Plate',
            value: bike.plateNumber,
          ),
          MtagInfoTile(
            icon: Icons.settings_outlined,
            label: 'Engine no.',
            value: bike.engineNumber,
          ),
          MtagInfoTile(
            icon: Icons.numbers_outlined,
            label: 'Chassis no.',
            value: bike.chassisNumber,
          ),
        ],
      ),
    );
  }
}
