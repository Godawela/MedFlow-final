// lib/services/image_picker_service.dart


// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from specific source with error handling
  static Future<File?> pickImageFromSource(
    ImageSource source, {
    BuildContext? context,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool showErrorSnackbar = true,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      
      if (context != null && showErrorSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    BuildContext? context,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool showErrorSnackbar = true,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      
      if (context != null && showErrorSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    }
  }

  /// Pick video from source
  static Future<File?> pickVideoFromSource(
    ImageSource source, {
    BuildContext? context,
    Duration? maxDuration,
    bool showErrorSnackbar = true,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      
      if (context != null && showErrorSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}