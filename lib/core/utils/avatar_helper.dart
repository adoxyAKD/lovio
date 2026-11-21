import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';

/// Helper to resolve [ImageProvider] from any avatar source:
/// - Web URL (`http://` or `https://`)
/// - Base64 Data URI (`data:image/...;base64,...`) or raw Base64 string
/// - Local device file path (`/data/user/...` or `C:\...`)
ImageProvider? getAvatarImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;

  // 1. Remote HTTP/HTTPS URL
  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
    return NetworkImage(photoUrl);
  }

  // 2. Base64 Data URI or raw base64 string
  if (photoUrl.startsWith('data:image') ||
      (photoUrl.length > 200 &&
          !photoUrl.contains('/') &&
          !photoUrl.contains('\\'))) {
    try {
      final commaIndex = photoUrl.indexOf(',');
      final b64String =
          commaIndex != -1 ? photoUrl.substring(commaIndex + 1) : photoUrl;
      final bytes = base64Decode(b64String);
      return MemoryImage(bytes);
    } catch (_) {}
  }

  // 3. Local file system path
  try {
    final file = File(photoUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}

  return null;
}

