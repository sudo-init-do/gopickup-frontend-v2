import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic text styles. Prefer these (or `Theme.of(context).textTheme`) over
/// inline `TextStyle(fontSize:, fontWeight:)` so typography stays consistent.
class AppTextStyles {
  static const String _family = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headingLg = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  /// Material [TextTheme] so `Theme.of(context).textTheme.*` resolves to these.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLg,
    headlineMedium: headingLg,
    titleLarge: headingMd,
    titleMedium: titleMd,
    bodyLarge: body,
    bodyMedium: bodySm,
    labelLarge: label,
    bodySmall: caption,
  );
}
