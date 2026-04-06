import 'package:flutter/material.dart';

enum HomeFestivalKind { blinkit, summer, hanuman, diwali }

/// Visual tokens for the rotating festival / promo header and surrounding strip.
class HomeFestivalVisuals {
  const HomeFestivalVisuals({
    required this.kind,
    required this.headerGradient,
    required this.headerEyebrowColor,
    required this.headerMinutesColor,
    required this.headerBodyColor,
    required this.showSurgeBadge,
    required this.stripBelowHeaderColor,
    required this.categoryCircleFill,
    required this.categoryCircleBorderSelected,
    required this.categoryLabelColor,
    required this.categoryIconColor,
    required this.searchBarBackground,
    required this.searchBarHintStyleColor,
    required this.searchBarIconColor,
    required this.profileCircleFill,
    required this.profileIconColor,
    required this.promoBackdropColor,
  });

  final HomeFestivalKind kind;
  final LinearGradient headerGradient;
  final Color headerEyebrowColor;
  final Color headerMinutesColor;
  final Color headerBodyColor;
  final bool showSurgeBadge;
  final Color stripBelowHeaderColor;
  final Color categoryCircleFill;
  final Color categoryCircleBorderSelected;
  final Color categoryLabelColor;
  final Color categoryIconColor;
  final Color searchBarBackground;
  final Color searchBarHintStyleColor;
  final Color searchBarIconColor;
  final Color profileCircleFill;
  final Color profileIconColor;
  final Color promoBackdropColor;

  /// Order used by legacy festival demo rotation (unused on main home).
  static const List<HomeFestivalVisuals> rotation = [summer, hanuman, diwali];

  /// Matches Blinkit dark-mode screenshots: black header, gold minutes, white copy.
  static const HomeFestivalVisuals blinkitDark = HomeFestivalVisuals(
    kind: HomeFestivalKind.blinkit,
    headerGradient: LinearGradient(
      colors: [
        Color(0xFF121212),
        Color(0xFF121212),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    headerEyebrowColor: Color(0xE6FFFFFF),
    headerMinutesColor: Color(0xFFFFCC00),
    headerBodyColor: Color(0xE6FFFFFF),
    showSurgeBadge: false,
    stripBelowHeaderColor: Color(0xFF121212),
    // Slightly lifted circle so icons read on #121212 (transparent looked “empty” on web).
    categoryCircleFill: Color(0xFF2C2C2E),
    categoryCircleBorderSelected: Color(0xFFFFFFFF),
    categoryLabelColor: Color(0xE6FFFFFF),
    categoryIconColor: Color(0xFFFFFFFF),
    searchBarBackground: Color(0xFF2C2C2E),
    searchBarHintStyleColor: Color(0x8AFFFFFF),
    searchBarIconColor: Color(0xB3FFFFFF),
    profileCircleFill: Color(0xFFFFFFFF),
    profileIconColor: Color(0xFF1C1C1E),
    promoBackdropColor: Color(0xFF121212),
  );

  static const HomeFestivalVisuals summer = HomeFestivalVisuals(
    kind: HomeFestivalKind.summer,
    headerGradient: LinearGradient(
      colors: [
        Color(0xFFFFE066),
        Color(0xFFFFD54F),
        Color(0xFFFFF8E1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    headerEyebrowColor: Color(0xDD000000),
    headerMinutesColor: Color(0xFF000000),
    headerBodyColor: Color(0xDD000000),
    showSurgeBadge: false,
    stripBelowHeaderColor: Color(0xFFF7F7F7),
    categoryCircleFill: Colors.white,
    categoryCircleBorderSelected: Colors.black,
    categoryLabelColor: Color(0xDD000000),
    categoryIconColor: Color(0xDD000000),
    searchBarBackground: Color(0xFF3A3A3C),
    searchBarHintStyleColor: Color(0x8AFFFFFF),
    searchBarIconColor: Color(0x8AFFFFFF),
    profileCircleFill: Color(0x1F000000),
    profileIconColor: Color(0xDD000000),
    promoBackdropColor: Color(0xFFF7F7F7),
  );

  static const HomeFestivalVisuals hanuman = HomeFestivalVisuals(
    kind: HomeFestivalKind.hanuman,
    headerGradient: LinearGradient(
      colors: [
        Color(0xFF6D4C41),
        Color(0xFF5D4037),
        Color(0xFF4E342E),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    headerEyebrowColor: Color(0xE6FFFFFF),
    headerMinutesColor: Colors.white,
    headerBodyColor: Color(0xE6FFFFFF),
    showSurgeBadge: true,
    stripBelowHeaderColor: Color(0xFF4E342E),
    categoryCircleFill: Color(0x33FFFFFF),
    categoryCircleBorderSelected: Colors.white,
    categoryLabelColor: Color(0xE6FFFFFF),
    categoryIconColor: Colors.white,
    searchBarBackground: Color(0xFF3E2723),
    searchBarHintStyleColor: Color(0x8AFFFFFF),
    searchBarIconColor: Color(0x8AFFFFFF),
    profileCircleFill: Color(0x33FFFFFF),
    profileIconColor: Colors.white,
    promoBackdropColor: Color(0xFF4E342E),
  );

  static const HomeFestivalVisuals diwali = HomeFestivalVisuals(
    kind: HomeFestivalKind.diwali,
    headerGradient: LinearGradient(
      colors: [
        Color(0xFFD32F2F),
        Color(0xFFC62828),
        Color(0xFFB71C1C),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    headerEyebrowColor: Color(0xE6FFFFFF),
    headerMinutesColor: Colors.white,
    headerBodyColor: Color(0xE6FFFFFF),
    showSurgeBadge: false,
    stripBelowHeaderColor: Color(0xFFC62828),
    categoryCircleFill: Color(0x33FFFFFF),
    categoryCircleBorderSelected: Colors.white,
    categoryLabelColor: Color(0xE6FFFFFF),
    categoryIconColor: Colors.white,
    searchBarBackground: Colors.white,
    searchBarHintStyleColor: Color(0x8A000000),
    searchBarIconColor: Color(0x8A000000),
    profileCircleFill: Color(0x33FFFFFF),
    profileIconColor: Colors.white,
    promoBackdropColor: Color(0xFFC62828),
  );
}
