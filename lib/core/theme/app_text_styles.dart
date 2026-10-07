import 'package:flutter/material.dart';

/// Text styles shared across screens.
class AppTextStyles {
  AppTextStyles._();

  /// Font for the MTAG wordmark. It ships with Android; other platforms fall
  /// back to their default font because no font files are bundled.
  static const String brandFontFamily = 'Roboto';

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
    height: 1.35,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
}
