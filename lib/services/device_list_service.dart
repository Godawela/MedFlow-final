import 'dart:convert';
import 'dart:io';

import 'package:med/models/category_model.dart';
import 'package:med/models/device_model.dart';
import 'package:http/http.dart' as http;


class DeviceListService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
   static Future<List<Device>> getDevicesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/devices/category/$category'),
      );

        if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching devices: $e');
    }
  }
  
  static Future<Category> getCategoryByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category/name/$name'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Category.fromJson(data);
      } else {
        throw ApiException('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Error fetching category: $e');
    }
  }

   static Future<void> updateCategory(
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

      request.fields['name'] = name;
      request.fields['description'] = description;

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
      
      if (response.statusCode != 200) {
        var responseBody = await response.stream.bytesToString();
        throw ApiException('Failed to update category: $responseBody');
      }
    } catch (e) {
      throw ApiException('Error updating category: $e');
    }
  }

  
}

class ApiException implements Exception {
  final String message;  
  ApiException(this.message);
  
  @override
  String toString() => message;
}