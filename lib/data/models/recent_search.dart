class RecentSearchEntry {
  const RecentSearchEntry({required this.query, this.thumbProductId});

  final String query;
  final String? thumbProductId;

  factory RecentSearchEntry.fromJson(Map<String, dynamic> json) {
    return RecentSearchEntry(
      query: json['query'] as String,
      thumbProductId: json['thumbProductId'] as String?,
    );
  }
}
