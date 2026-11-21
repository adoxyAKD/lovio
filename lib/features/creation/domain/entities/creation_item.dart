enum CreationType {
  shortBook,
  page,
  card,
  loveLetter;

  String get name => toString().split('.').last;
}

class CreationItem {
  final String id;
  final String title;
  final CreationType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String? coverUrl;
  final int pageCount;

  const CreationItem({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.coverUrl,
    this.pageCount = 1,
  });
}
