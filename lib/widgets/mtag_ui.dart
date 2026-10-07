import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/core/theme/app_text_styles.dart';
import 'package:mtag_queue_skipper/widgets/google_logo.dart';

/// Shared casual UI pieces — matches the home screen vibe, not corporate.
class MtagUi {
  MtagUi._();

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class MtagScreen extends StatelessWidget {
  const MtagScreen({
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

class MtagCard extends StatelessWidget {
  const MtagCard({
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

class MtagHighlightBanner extends StatelessWidget {
  const MtagHighlightBanner({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.info_outline,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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

class MtagInfoTile extends StatelessWidget {
  const MtagInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.black45),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

class MtagPrimaryButton extends StatelessWidget {
  const MtagPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

class MtagOutlinedButton extends StatelessWidget {
  const MtagOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class MtagGoogleButton extends StatelessWidget {
  const MtagGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MtagAuthLayout extends StatelessWidget {
  const MtagAuthLayout({
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

class MtagOrDivider extends StatelessWidget {
  const MtagOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.borderLight)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: TextStyle(color: Colors.black45)),
          ),
          Expanded(child: Divider(color: AppColors.borderLight)),
        ],
      ),
    );
  }
}
