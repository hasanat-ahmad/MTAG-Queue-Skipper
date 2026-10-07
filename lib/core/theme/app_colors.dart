import 'package:flutter/material.dart';

/// Colour palette for the whole app.
///
/// Widgets reference these tokens instead of hard-coding hex values, so a
/// brand change happens in one place.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────
  /// MTAG green.
  static const Color primary = Color(0xFF01411C);

  /// Lighter green used as the end stop of the brand gradient.
  static const Color primaryLight = Color(0xFF027A2E);

  /// Mint background behind green icons and badges.
  static const Color primarySoft = Color(0xFFE8F5E9);

  static const Color accent = Color(0xFF1A73E8);

  /// Blue-tinted background for highlighted blocks (e.g. the token banner).
  static const Color accentSoft = Color(0xFFEEF3FF);

  // ── Surfaces ────────────────────────────────────────────
  static const Color screenBackground = Color(0xFFF5F5F5);

  /// Grey background behind neutral icons.
  static const Color neutralSoft = Color(0xFFF2F2F2);

  // ── Borders ─────────────────────────────────────────────
  /// Form fields and message cards.
  static const Color border = Color(0xFFE0E0E0);

  /// Section cards, dividers and outlined secondary buttons.
  static const Color borderLight = Color(0xFFE8E8E8);

  // ── Status ──────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningSoft = Color(0xFFFFF8E1);
  static const Color warningBorder = Color(0xFFFFE082);
}

/// MTAG brand gradients.
class AppGradients {
  AppGradients._();

  /// Left-to-right gradient for banners and avatars.
  static const LinearGradient brand = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  /// Diagonal variant for hero cards (welcome card, issued MTAG card).
  static const LinearGradient brandDiagonal = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
