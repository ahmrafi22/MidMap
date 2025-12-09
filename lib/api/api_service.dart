import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // Resize image to 800x600
  Future<List<int>> _resizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final resized = img.copyResize(image, width: 800, height: 600);
    return img.encodeJpg(resized);
  }

  // Get all entities
  Future<List<dynamic>> getEntities() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load entities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load entities: $e');
    }
  }

  // Create new entity
  Future<Map<String, dynamic>> createEntity({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      if (imageFile != null) {
        // Resize image 
        final resizedImage = await _resizeImage(imageFile);
        final originalFilename = path.basename(imageFile.path);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            resizedImage,
            filename: originalFilename,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse;
      } else {
        throw Exception('Failed to create entity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create entity: $e');
    }
  }

  // Update entity
  Future<Map<String, dynamic>> updateEntity({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      if (imageFile == null) {
        // Use application/x-www-form-urlencoded when there is no image
        final response = await http.put(
          Uri.parse(baseUrl),
          headers: {
            HttpHeaders.contentTypeHeader:
                'application/x-www-form-urlencoded; charset=UTF-8',
          },
          body: {
            'id': id.toString(),
            'title': title,
            'lat': lat.toString(),
            'lon': lon.toString(),
          },
          encoding: Encoding.getByName('utf-8'),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception(
            'Failed to update entity: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        // Use multipart/form-data when updating image
        var request = http.MultipartRequest('PUT', Uri.parse(baseUrl));
        request.fields['id'] = id.toString();
        request.fields['title'] = title;
        request.fields['lat'] = lat.toString();
        request.fields['lon'] = lon.toString();

        // Resize image to 800x600
        final resizedImage = await _resizeImage(imageFile);
        final originalFilename = path.basename(imageFile.path);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            resizedImage,
            filename: originalFilename,
          ),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          return json.decode(responseBody);
        } else {
          throw Exception(
            'Failed to update entity: ${response.statusCode} - $responseBody',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to update entity: $e');
    }
  }

  // Delete entity
  Future<Map<String, dynamic>> deleteEntity(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl?id=$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete entity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete entity: $e');
    }
  }
}
