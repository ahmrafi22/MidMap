import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  /// Create a new entry
  /// Takes title, latitude, longitude, and image file
  /// Returns the created entity's ID
  static Future<Map<String, dynamic>> createEntry({
    required String title,
    required double lat,
    required double lon,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add form fields
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create entry: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating entry: $e');
    }
  }

  /// Retrieve all entries
  /// Returns a list of all entities
  static Future<List<dynamic>> viewAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to retrieve entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving entries: $e');
    }
  }

  /// Update an existing entry
  /// If image is null, keeps the previous image
  /// If image is provided, updates with new image using form data
  static Future<Map<String, dynamic>> updateEntry({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? image,
  }) async {
    try {
      if (image != null) {
        // If image is provided, use multipart form data
        var request = http.MultipartRequest('PUT', Uri.parse(baseUrl));

        request.fields['id'] = id.toString();
        request.fields['title'] = title;
        request.fields['lat'] = lat.toString();
        request.fields['lon'] = lon.toString();

        // Add new image file
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to update entry: ${response.statusCode}');
        }
      } else {
        // If no image, use x-www-form-urlencoded
        final response = await http.put(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'id': id.toString(),
            'title': title,
            'lat': lat.toString(),
            'lon': lon.toString(),
          },
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to update entry: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error updating entry: $e');
    }
  }

  /// Delete an entry by ID
  /// Permanently removes the record
  static Future<Map<String, dynamic>> deleteEntry(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl?id=$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete entry: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting entry: $e');
    }
  }
}
