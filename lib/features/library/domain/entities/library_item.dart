import 'package:lovio/features/creation/domain/entities/creation_item.dart';

class LibraryItem {
  final CreationItem item;
  final bool isDraft;
  final bool isShared;
  final String? sharedWith;

  const LibraryItem({
    required this.item,
    this.isDraft = false,
    this.isShared = false,
    this.sharedWith,
  });
}
