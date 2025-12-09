import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCacheService {
  static final ImageCacheService instance = ImageCacheService._init();

  ImageCacheService._init();

  // Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'image_cache'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  // Download and cache an image
  Future<String?> cacheImage(String imageUrl) async {
    try {
      // Skip if URL is empty
      if (imageUrl.isEmpty) {
        return null;
      }

      // Create full URL if it's a relative path
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : 'https://labs.anontech.info/cse489/t3/$imageUrl';

      // Generate a unique filename based on the URL
      final fileName = _getFileNameFromUrl(imageUrl);
      final cacheDir = await _getCacheDirectory();
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);

      // Check if already cached
      if (await file.exists()) {
        return filePath;
      }

      // Download the image
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  // Get cached image file
  Future<File?> getCachedImage(String imageUrl) async {
    try {
      final fileName = _getFileNameFromUrl(imageUrl);
      final cacheDir = await _getCacheDirectory();
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting cached image: $e');
      return null;
    }
  }

  // Delete a cached image
  Future<void> deleteCachedImage(String imageUrl) async {
    try {
      final fileName = _getFileNameFromUrl(imageUrl);
      final cacheDir = await _getCacheDirectory();
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting cached image: $e');
    }
  }

  // Clear all cached images
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache size
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  // Generate a safe filename from URL
  String _getFileNameFromUrl(String url) {
    // Extract the filename from the URL or create a hash-based name
    final uri = Uri.tryParse(url);
    String fileName;

    if (uri != null && uri.pathSegments.isNotEmpty) {
      fileName = uri.pathSegments.last;
    } else {
      // Use the URL as-is if it's already just a filename
      fileName = url.split('/').last;
    }

    // Sanitize the filename
    fileName = fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');

    // Ensure it has an extension
    if (!fileName.contains('.')) {
      fileName += '.png';
    }

    return fileName;
  }

  // Check if an image is cached
  Future<bool> isCached(String imageUrl) async {
    try {
      final fileName = _getFileNameFromUrl(imageUrl);
      final cacheDir = await _getCacheDirectory();
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
