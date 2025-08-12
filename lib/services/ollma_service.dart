import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:med/config/api_keys.dart';

class OllamaService {
  static const String apiKey = ApiKeys.geminiApiKey;
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> generateResponse(String prompt) async {
    try {
      debugPrint('Sending prompt to Gemini: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': _buildMedicalPrompt(prompt)
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topP': 0.8,
          'topK': 40,
          'maxOutputTokens': 300,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          },
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_ONLY_HIGH'
          }
        ]
      };

      debugPrint('Request to: $apiUrl?key=$apiKey');

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String responseText = '';
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          responseText = data['candidates'][0]['content']['parts'][0]['text'] ?? '';
        }
        
        // Clean up response
        responseText = responseText.trim();
        
        if (responseText.isEmpty) {
          responseText = 'I\'m here to help with your health questions. Could you please provide more details about your concern?';
        }
        
        // Add medical disclaimer if not present
        if (!responseText.toLowerCase().contains('consult') && 
            !responseText.toLowerCase().contains('doctor') && 
            !responseText.toLowerCase().contains('professional')) {
          responseText += '\n\n⚠️ Always consult with a healthcare professional for proper medical advice and diagnosis.';
        }
        
        return responseText;
        
      } else if (response.statusCode == 503) {
        return '⏳ Gemini service is busy. Please wait a few seconds and try again.';
      } else if (response.statusCode == 429) {
        return '⚠️ Rate limit exceeded. Please wait a moment before trying again.';
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']['message'] ?? 'Invalid request';
        return '❌ Request error: $errorMsg';
      } else if (response.statusCode == 403) {
        return '🔑 API key invalid or quota exceeded. Please check your Google Cloud console.';
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']['message'] ?? 'Unknown error';
        return '❌ Service error: $errorMsg';
      }
      
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: $e');
      return '⏱️ Request timeout. Please try again.';
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      return '🌐 No internet connection. Please check your network.';
    } catch (e) {
      debugPrint('Error: $e');
      return '❌ Something went wrong: ${e.toString()}';
    }
  }

  String _buildMedicalPrompt(String userInput) {
    return '''You are a helpful medical assistant. Provide brief, informative responses about health topics.

Guidelines:
- Always remind users to consult healthcare professionals for serious concerns
- Provide general information, not specific medical diagnoses
- Keep responses concise and helpful (under 200 words)
- Be empathetic and professional
- Never replace professional medical advice

User question: $userInput

Response:''';
  }

  Future<bool> checkConnection() async {
    try {
      debugPrint('Testing connection to Gemini API');
      
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello'}
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Connection test status: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 503;
      
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }
}