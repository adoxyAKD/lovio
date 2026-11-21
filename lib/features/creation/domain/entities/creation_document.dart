import 'creation_item.dart';

enum SyncStatus {
  localOnly,
  syncing,
  synced,
  syncFailed;

  String get name => toString().split('.').last;

  String get label {
    switch (this) {
      case SyncStatus.localOnly:
        return 'Saved on Device';
      case SyncStatus.syncing:
        return 'Uploading to Cloud...';
      case SyncStatus.synced:
        return 'Synced to Cloud';
      case SyncStatus.syncFailed:
        return 'Sync Failed';
    }
  }
}

/// Core Document model representing a saved creation in Lovio
class CreationDocument {
  final String id;
  final String title;
  final CreationType type;
  final Map<String, dynamic> content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final int pageCount;
  final String? coverGradientKey;
  final SyncStatus syncStatus;
  final String? cloudDocId;
  final DateTime? lastSyncedAt;
  final String? localFilePath;

  const CreationDocument({
    required this.id,
    required this.title,
    required this.type,
    this.content = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.pageCount = 1,
    this.coverGradientKey = 'primary',
    this.syncStatus = SyncStatus.localOnly,
    this.cloudDocId,
    this.lastSyncedAt,
    this.localFilePath,
  });

  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get isLocalOnly => syncStatus == SyncStatus.localOnly;
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  CreationDocument copyWith({
    String? id,
    String? title,
    CreationType? type,
    Map<String, dynamic>? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? pageCount,
    String? coverGradientKey,
    SyncStatus? syncStatus,
    String? cloudDocId,
    DateTime? lastSyncedAt,
    String? localFilePath,
  }) {
    return CreationDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      pageCount: pageCount ?? this.pageCount,
      coverGradientKey: coverGradientKey ?? this.coverGradientKey,
      syncStatus: syncStatus ?? this.syncStatus,
      cloudDocId: cloudDocId ?? this.cloudDocId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'pageCount': pageCount,
      'coverGradientKey': coverGradientKey,
      'syncStatus': syncStatus.name,
      'cloudDocId': cloudDocId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'localFilePath': localFilePath,
    };
  }

  factory CreationDocument.fromJson(Map<String, dynamic> json) {
    return CreationDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      type: CreationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CreationType.shortBook,
      ),
      content: (json['content'] as Map<String, dynamic>?) ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      pageCount: (json['pageCount'] as int?) ?? 1,
      coverGradientKey: (json['coverGradientKey'] as String?) ?? 'primary',
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => SyncStatus.localOnly,
      ),
      cloudDocId: json['cloudDocId'] as String?,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      localFilePath: json['localFilePath'] as String?,
    );
  }
}
