import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api_service.dart';
import '../db/database_helper.dart';
import '../db/image_cache_service.dart';
import '../models/map_entry.dart' as model;

class MapEntryRepository {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImageCacheService _imageCacheService = ImageCacheService.instance;
  final Connectivity _connectivity = Connectivity();

  // Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // connectivity_plus returns a List<ConnectivityResult>
      return connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('Connectivity check error: $e');
      // Assume we have internet if check fails
      return true;
    }
  }

  // Get all entries - tries API first, falls back to database
  Future<List<model.MapEntry>> getAllEntries({
    bool forceRefresh = false,
  }) async {
    try {
      final hasInternet = await hasInternetConnection();

      if (hasInternet && forceRefresh) {
        // Fetch from API
        final response = await _apiService.getEntities();
        final entries = response
            .map((json) => model.MapEntry.fromJson(json))
            .toList();

        // Save to database and cache images
        await _saveEntriesToDatabase(entries);

        return entries;
      } else if (hasInternet) {
        // Try to fetch from API, but don't fail if it doesn't work
        try {
          final response = await _apiService.getEntities();
          final entries = response
              .map((json) => model.MapEntry.fromJson(json))
              .toList();

          // Save to database and cache images in background
          _saveEntriesToDatabase(entries);

          return entries;
        } catch (e) {
          // Fall back to database
          return await _getEntriesFromDatabase();
        }
      } else {
        // No internet, get from database
        return await _getEntriesFromDatabase();
      }
    } catch (e) {
      // If all else fails, try database
      return await _getEntriesFromDatabase();
    }
  }

  // Get entries from local database
  Future<List<model.MapEntry>> _getEntriesFromDatabase() async {
    try {
      final dbEntries = await _dbHelper.getAllEntries();
      print('Database entries: $dbEntries');
      return dbEntries.map((json) {
        try {
          return model.MapEntry.fromJson(json);
        } catch (e) {
          print('Error parsing database entry: $json, Error: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Database read error: $e');
      return [];
    }
  }

  // Save entries to database and cache images
  Future<void> _saveEntriesToDatabase(List<model.MapEntry> entries) async {
    try {
      // Save entries to database
      await _dbHelper.insertEntries(entries);

      // Cache images in background
      for (var entry in entries) {
        if (entry.image != null && entry.image!.isNotEmpty) {
          _imageCacheService.cacheImage(entry.image!).catchError((e) {
            print('Failed to cache image for entry ${entry.id}: $e');
            return null;
          });
        }
      }
    } catch (e) {
      print('Database write error: $e');
      // Continue without database - app will work but won't cache
    }
  }

  // Extract entry from API response (handles different response formats)
  Map<String, dynamic> _extractEntryFromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Check if response is wrapped in a "data" object
      if (response.containsKey('data') && response['data'] is Map) {
        return response['data'] as Map<String, dynamic>;
      }
      // Check if response is wrapped in other common structures
      if (response.containsKey('result') && response['result'] is Map) {
        return response['result'] as Map<String, dynamic>;
      }
      // Response is the entry itself
      return response;
    }
    throw Exception('Invalid API response format: $response');
  }

  // Create new entry
  Future<model.MapEntry> createEntry({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot create new entry.');
    }

    try {
      // Create via API
      final response = await _apiService.createEntity(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: imageFile,
      );

      print('API Response: $response');

      // Extract entry data from response
      final entryData = _extractEntryFromResponse(response);

      // Convert response to MapEntry
      final newEntry = model.MapEntry.fromJson(entryData);

      // Refresh all entries from API to update database
      await getAllEntries(forceRefresh: true);

      return newEntry;
    } catch (e) {
      print('Create entry error: $e');
      rethrow;
    }
  }

  // Update entry
  Future<model.MapEntry> updateEntry({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot update entry.');
    }

    // Update via API
    final response = await _apiService.updateEntity(
      id: id,
      title: title,
      lat: lat,
      lon: lon,
      imageFile: imageFile,
    );

    // Extract entry data from response
    final entryData = _extractEntryFromResponse(response);

    // Convert response to MapEntry
    final updatedEntry = model.MapEntry.fromJson(entryData);

    // Update in database
    await _dbHelper.updateEntry(updatedEntry);

    // Cache new image if provided
    if (updatedEntry.image != null && updatedEntry.image!.isNotEmpty) {
      await _imageCacheService.cacheImage(updatedEntry.image!);
    }

    return updatedEntry;
  }

  // Delete entry
  Future<void> deleteEntry(int id) async {
    // Check internet connection
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw Exception('No internet connection. Cannot delete entry.');
    }

    // Get entry to find image URL
    final dbEntry = await _dbHelper.getEntryById(id);
    final imageUrl = dbEntry?['image'] as String?;

    // Delete via API
    await _apiService.deleteEntity(id);

    // Delete from database
    await _dbHelper.deleteEntry(id);

    // Delete cached image
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _imageCacheService.deleteCachedImage(imageUrl);
    }
  }

  // Get cached image path for an entry
  Future<String?> getCachedImagePath(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    final cachedFile = await _imageCacheService.getCachedImage(imageUrl);
    return cachedFile?.path;
  }

  // Clear all cached data
  Future<void> clearCache() async {
    await _dbHelper.clearAllEntries();
    await _imageCacheService.clearCache();
  }
}
