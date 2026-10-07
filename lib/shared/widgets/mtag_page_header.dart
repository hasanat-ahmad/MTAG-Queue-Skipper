import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';

/// Title + subtitle shown at the top of a page, with an optional icon tile.
class MtagPageHeader extends StatelessWidget {
  const MtagPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.pageTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.pageSubtitle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
