/// Spacing & radius scale. Use these instead of magic numbers so layout is
/// consistent across screens.
///
/// Scale (4-based): xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 40
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Standard screen edge padding.
  static const double screen = 16;
}

/// Corner-radius scale.
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}
