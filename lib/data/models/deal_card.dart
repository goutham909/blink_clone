import 'package:flutter/material.dart';

class DealCardData {
  const DealCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountLabel,
    required this.accentHex,
    this.thumbnailHints = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String discountLabel;
  final String accentHex;
  final List<String> thumbnailHints;

  Color get accentColor {
    final hex = accentHex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFFEA580C);
  }

  bool get isLightBackground => accentColor.computeLuminance() > 0.75;

  factory DealCardData.fromJson(Map<String, dynamic> json) {
    return DealCardData(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      discountLabel: json['discountLabel'] as String,
      accentHex: json['accentHex'] as String? ?? 'FFEA580C',
      thumbnailHints: (json['thumbnailHints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}
