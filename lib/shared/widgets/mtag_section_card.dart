import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';

/// White, bordered card that groups related content under an optional title.
///
/// Not to be confused with the MTAG card the rider collects; that one is
/// drawn by `MtagCardPreview` in the card issuance feature.
class MtagSectionCard extends StatelessWidget {
  const MtagSectionCard({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.sectionLabel),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
