import 'package:flutter/material.dart';

/// Centralized color tokens for the whole app.
///
/// Screens should reference these instead of hardcoding `Color(0xFF…)`.
/// Brand + semantic tokens live here; per-role accent colors are grouped at
/// the bottom so each area stays visually distinct but still consistent.
class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3B7D23);
  static const Color primaryDark = Color(0xFF2D5F1A);
  static const Color primaryLight = Color(0xFFE8F3E5);
  static const Color secondary = Color(0xFFF5F5F3);
  static const Color accent = Color(0xFFF59E0B);
  static const Color primarySage = Color(0xFF98BF8F);

  // ─── Surfaces / backgrounds ─────────────────────────────────────────────────
  static const Color surface = Color(0xFFFAF9F6);
  static const Color background = Color(0xFFF9FAFB);
  static const Color backgroundSubtle = Color(0xFFF1F5F9);
  static const Color card = Colors.white;

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color onSurface = Colors.black87;
  static const Color onPrimary = Colors.white;
  static const Color textPrimary = Color(0xFF111827); // headings
  static const Color textSecondary = Color(0xFF6B7280); // body / labels
  static const Color textTertiary = Color(0xFF94A3B8); // captions / hints
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ─── Borders / dividers ──────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFD1D5DB);

  // ─── Semantic status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color destructive = Color(0xFFEF4444);

  // ─── Per-area accents (kept distinct, but named & centralized) ────────────────
  static const Color clientAccent = primary; // green
  static const Color driverAccent = Color(0xFFF97316); // orange
  static const Color vendorAccent = Color(0xFFA855F7); // purple
  static const Color adminAccent = Color(0xFF4F46E5); // indigo

  // ─── Integrations ────────────────────────────────────────────────────────────
  static const Color whatsapp = Color(0xFF25D366);
}
