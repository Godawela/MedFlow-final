import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:med/models/quick_tip.dart';

class QuickTipsService {
  static const String baseUrl = 'https://medflow-phi.vercel.app';

  static Future<QuickTipsResponse?> getQuickTips(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quicktips/category/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return QuickTipsResponse.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching quick tips: $e');
      return null;
    }
  }
}