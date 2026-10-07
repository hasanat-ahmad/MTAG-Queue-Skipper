import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';

/// Standard page frame: grey background and a flat app bar with a bold title.
class MtagScaffold extends StatelessWidget {
  const MtagScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: AppTextStyles.appBarTitle),
        actions: actions,
      ),
      body: body,
    );
  }
}
