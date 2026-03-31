class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.distanceKm,
    this.phoneNumber,
  });

  final String id;
  final String label;
  final String fullAddress;
  final double distanceKm;
  final String? phoneNumber;

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
