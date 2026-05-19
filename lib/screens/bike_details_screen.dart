import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
import 'package:provider/provider.dart';

class BikeDetailsScreen extends StatelessWidget {
  const BikeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bike = context.watch<BikeDetailsProvider>().bikeDetails;
    final user = context.watch<AuthProvider>().user;

    if (bike == null) {
      return MtagScreen(
        title: 'Bike Details',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.two_wheeler_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nothing here yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register your bike and your details will show up.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                MtagPrimaryButton(
                  label: 'Register bike',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/bike-register'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MtagScreen(
      title: 'Bike Details',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF01411C), Color(0xFF027A2E)],
              ),
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
                        user?.name.trim().isNotEmpty == true ? user!.name : '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        bike.plateNumber,
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
          ),
          const SizedBox(height: 14),
          MtagCard(
            title: 'Owner',
            child: Column(
              children: [
                MtagInfoTile(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: user?.name.trim().isNotEmpty == true ? user!.name : '—',
                ),
                MtagInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user?.phoneNumber.trim().isNotEmpty == true
                      ? user!.phoneNumber
                      : '—',
                ),
                MtagInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'CNIC',
                  value: user?.cnic.trim().isNotEmpty == true ? user!.cnic : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MtagCard(
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
                  value: bike.engineNo,
                ),
                MtagInfoTile(
                  icon: Icons.numbers_outlined,
                  label: 'Chassis no.',
                  value: bike.chasisNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
