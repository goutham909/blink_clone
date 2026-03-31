class CategoryChipData {
  const CategoryChipData({required this.id, required this.label});

  final String id;
  final String label;

  factory CategoryChipData.fromJson(Map<String, dynamic> json) {
    return CategoryChipData(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}
