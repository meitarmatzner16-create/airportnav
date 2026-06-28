class AppSpacing {
  AppSpacing._();

  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // In-between values for fine-tuning
  static const double smMd = 12;
  static const double mdLg = 20;

  /// Default horizontal screen content padding — used as the gutter that
  /// gives the layout breathing room. Slightly larger than `md` for a
  /// more spacious, premium feel.
  static const double gutter = 20;

  /// Vertical breathing room between major sections within a screen.
  static const double sectionGap = 28;

  // Border radius
  static const double radiusXs = 6;
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  // Icon sizes
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Component sizes
  static const double buttonHeight = 52;
  static const double chipRowHeight = 44;
  static const double inputFieldRadius = 14;

  // Elevation
  static const double cardElevation = 1;
  static const double appBarElevation = 0;
}
