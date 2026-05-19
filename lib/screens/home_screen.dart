import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _screenBg = Color(0xFFF5F5F5);
  static const Color _highlightBg = Color(0xFFEEF3FF);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bike = context.watch<BikeDetailsProvider>();
    final userName = auth.user?.name.trim().isNotEmpty == true
        ? auth.user!.name.trim()
        : 'User';
    final firstName = userName.split(' ').first;

    final items = [
      _NavItem(
        title: 'Register Bike',
        subtitle: 'Add your motorcycle details',
        icon: Icons.electric_bike_outlined,
        iconBg: const Color(0xFFE8F5E9),
        iconColor: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, '/bike-register'),
      ),
      _NavItem(
        title: 'My Token',
        subtitle: 'Track queue status & wait time',
        icon: Icons.confirmation_number_outlined,
        iconBg: _highlightBg,
        iconColor: AppColors.accent,
        onTap: () => Navigator.pushNamed(context, '/token-status'),
      ),
      _NavItem(
        title: 'Collect MTAG Card',
        subtitle: 'Verify face & receive your card',
        icon: Icons.credit_card_outlined,
        iconBg: const Color(0xFFE8F5E9),
        iconColor: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, '/mtag-card'),
        highlight: bike.hasToken && !bike.isCardCollected,
      ),
      _NavItem(
        title: 'Bike Details',
        subtitle: 'Plate, engine & registration info',
        icon: Icons.two_wheeler_outlined,
        iconBg: const Color(0xFFF2F2F2),
        iconColor: Colors.black87,
        onTap: () => Navigator.pushNamed(context, '/bike-details'),
      ),
      _NavItem(
        title: 'Profile',
        subtitle: 'Account & personal information',
        icon: Icons.person_outline_rounded,
        iconBg: Colors.black,
        iconColor: Colors.white,
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
    ];

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'MTAG',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: AppFonts.primaryFont,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _WelcomeCard(firstName: firstName),
            if (bike.hasToken) ...[
              const SizedBox(height: 14),
              _TokenStatusCard(
                tokenNumber: bike.tokenNumber!,
                status: bike.displayTokenStatus,
                estimatedTime: bike.displayEstimatedTime,
                onTap: () => Navigator.pushNamed(context, '/token-status'),
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
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActionCard(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF01411C), Color(0xFF027A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'QUEUE SKIPPER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.two_wheeler_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Hello, $firstName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Register, pay, and collect your MTAG card — all in one place.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenStatusCard extends StatelessWidget {
  const _TokenStatusCard({
    required this.tokenNumber,
    required this.status,
    required this.estimatedTime,
    required this.onTap,
  });

  final String tokenNumber;
  final String status;
  final String estimatedTime;
  final VoidCallback onTap;

  bool get _isCollected => status == 'Card Issued';

  Color get _statusColor {
    if (_isCollected) return AppColors.success;
    final normalized = status.toLowerCase();
    if (normalized.contains('pending')) return AppColors.warning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeScreen._highlightBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your active token',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tokenNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Est. time: $estimatedTime',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Colors.black38,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: item.highlight
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: const Color(0xFFE8E8E8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (item.highlight)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'READY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final bool highlight;

  const _NavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.highlight = false,
  });
}
