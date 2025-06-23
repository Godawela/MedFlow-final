import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Get devices by category
  static Future<List<dynamic>> getDevicesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/devices/category/$category'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching devices: $e');
    }
  }

  // Get category description by name
  static Future<Map<String, dynamic>> getCategoryByName(String categoryName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category/name/$categoryName'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch category description');
      }
    } catch (e) {
      throw Exception('Error fetching category description: $e');
    }
  }

  // Update category
  static Future<Map<String, dynamic>> updateCategory(
    String categoryId,
    String name,
    String description, {
    File? imageFile,
    bool removeImage = false,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/category/$categoryId'),
      );

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;

      // Handle image operations
      if (removeImage) {
        request.fields['removeImage'] = 'true';
      } else if (imageFile != null) {
        var imageStream = http.ByteStream(imageFile.openRead());
        var imageLength = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to update category: $responseBody');
      }
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  // Delete category
  static Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/category/$categoryId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Delete failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // Get all categories
  static Future<List<dynamic>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category'),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Helper method to construct full image URL
  static String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // Convert backslashes to forward slashes for URL
    String cleanImagePath = imagePath.replaceAll('\\', '/');
    
    // Construct full URL
    return '$baseUrl/../$cleanImagePath';
  }
}