import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'https://medflow-phi.vercel.app/api';
  
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

static String? getImageUrl(String? imagePath) {
  print('=== getImageUrl DEBUG ===');
  print('Input imagePath: $imagePath');
  
  if (imagePath == null || imagePath.isEmpty) {
    print('Image path is null or empty');
    return null;
  }
  
  // Check if it's already a full URL (like Cloudinary URLs)
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    print('Image path is already a full URL, returning as-is: $imagePath');
    return imagePath; // Return as-is since it's already a complete URL
  }
  
  // Only for relative paths - construct full URL with your server
  String cleanImagePath = imagePath.replaceAll('\\', '/');
  if (cleanImagePath.startsWith('/')) {
    cleanImagePath = cleanImagePath.substring(1);
  }
  
  String constructedUrl = '$baseUrl/upload/$cleanImagePath';
  print('Constructed URL for relative path: $constructedUrl');
  return constructedUrl;
}


}
// Additional debugging helper class
class ImageUrlDebugger {
  static void debugImageUrl(String? imagePath) {
    print('=== IMAGE URL DEBUG ===');
    print('Original path: $imagePath');
    print('Is null or empty: ${imagePath == null || imagePath.isEmpty}');
    
    if (imagePath != null && imagePath.isNotEmpty) {
      print('Starts with http://: ${imagePath.startsWith('http://')}');
      print('Starts with https://: ${imagePath.startsWith('https://')}');
      print('Contains cloudinary: ${imagePath.contains('cloudinary.com')}');
      print('Final URL: ${CategoryService.getImageUrl(imagePath)}');
    }
    print('======================');
  }
}