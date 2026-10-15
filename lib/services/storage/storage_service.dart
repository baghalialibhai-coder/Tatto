// lib/services/storage/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      final id = fileName ?? const Uuid().v4();
      final ref = _storage.ref().child('$path/$id');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadSignature({
    required File file,
    required String userId,
  }) async {
    return uploadFile(
      file: file,
      path: 'signatures/$userId',
      fileName: '${DateTime.now().millisecondsSinceEpoch}.png',
    );
  }

  Future<String> uploadPhoto({
    required File file,
    required String userId,
  }) async {
    return uploadFile(
      file: file,
      path: 'photos/$userId',
      fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  Future<String> uploadDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    return uploadFile(
      file: file,
      path: 'documents/$userId/$documentType',
      fileName: '${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<List<String>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      final urls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}