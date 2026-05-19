import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class LocalProfileImageStorage {
  Future<String> saveProfileImage({
    required String userId,
    required String originalFileName,
    required Uint8List bytes,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final profileImagesDir = Directory('${directory.path}/as_new_inmotions/profile_images');

    if (!await profileImagesDir.exists()) {
      await profileImagesDir.create(recursive: true);
    }

    final extension = _extensionFromName(originalFileName);
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${profileImagesDir.path}/profile_$safeUserId$extension');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _extensionFromName(String fileName) {
    final clean = fileName.toLowerCase().trim();
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == clean.length - 1) return '.jpg';

    final extension = clean.substring(dotIndex);
    const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
    return allowed.contains(extension) ? extension : '.jpg';
  }
}
