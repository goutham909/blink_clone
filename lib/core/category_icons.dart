import 'package:flutter/material.dart';

IconData iconForCategoryName(String name) {
  switch (name) {
    case 'summer':
      return Icons.wb_sunny_outlined;
    case 'electronics':
      return Icons.devices_outlined;
    case 'beauty':
      return Icons.spa_outlined;
    case 'pharma':
      return Icons.medication_outlined;
    case 'dairy':
      return Icons.local_drink_outlined;
    case 'snacks':
      return Icons.fastfood_outlined;
    case 'beverage':
      return Icons.local_bar_outlined;
    case 'kitchen':
      return Icons.kitchen_outlined;
    case 'all':
    default:
      return Icons.apps_outlined;
  }
}
