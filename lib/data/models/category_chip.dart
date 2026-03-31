class CategoryChipData {
  const CategoryChipData({
    required this.id,
    required this.label,
    this.iconName = 'all',
    this.badgeText,
  });

  final String id;
  final String label;
  final String iconName;
  final String? badgeText;

  factory CategoryChipData.fromJson(Map<String, dynamic> json) {
    return CategoryChipData(
      id: json['id'] as String,
      label: json['label'] as String,
      iconName: json['iconName'] as String? ?? 'all',
      badgeText: json['badgeText'] as String?,
    );
  }
}
