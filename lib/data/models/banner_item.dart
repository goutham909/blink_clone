import 'package:flutter/material.dart';

class BannerItem {
  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    final raw = (json['accentHex'] as String? ?? 'FF00A651').replaceAll('#', '');
    final value = int.parse(raw, radix: 16);
    final color = raw.length == 8
        ? Color(value)
        : Color(0xFF000000 | value);
    return BannerItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      accentColor: color,
    );
  }
}
