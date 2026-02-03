import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Service for Firebase Storage operations (media uploads)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload a file and return the download URL
  Future<String> uploadFile({
    required File file,
    required String userId,
    required String secretId,
  }) async {
    // Generate unique filename
    final extension = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$extension';
    final path = 'secrets/$userId/$secretId/$fileName';

    // Upload file
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);

    // Wait for upload to complete
    final snapshot = await uploadTask;

    // Get download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Upload multiple files and return list of download URLs
  Future<List<String>> uploadFiles({
    required List<File> files,
    required String userId,
    required String secretId,
  }) async {
    final urls = <String>[];

    for (final file in files) {
      final url = await uploadFile(
        file: file,
        userId: userId,
        secretId: secretId,
      );
      urls.add(url);
    }

    return urls;
  }

  /// Delete a file by URL
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // File might already be deleted, ignore error
    }
  }

  /// Delete all files for a secret
  Future<void> deleteSecretFiles({
    required String userId,
    required String secretId,
  }) async {
    try {
      final ref = _storage.ref().child('secrets/$userId/$secretId');
      final result = await ref.listAll();

      for (final item in result.items) {
        await item.delete();
      }
    } catch (e) {
      // Folder might not exist, ignore error
    }
  }
}
