import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class OllamaService {
static const String baseUrl = 'http://10.0.2.2:11434';
  static const String model = 'llama3.2:3b';
  
  Future<String> generateResponse(String prompt) async {
    try {
      print('Sending prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');
      print('Full prompt length: ${prompt.length}');
      
      final requestBody = {
        'model': model,
        'prompt': _buildMedicalPrompt(prompt),
        'stream': false,
        'options': {
          'temperature': 0.7,
          'top_p': 0.9,
          'num_predict': 500, // Use num_predict instead of max_tokens for Ollama
        }
      };
      
      print('Request body: ${jsonEncode(requestBody).substring(0, 200)}...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 60)); // Increased timeout
      
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] ?? 'Sorry, I couldn\'t generate a response.';
        print('Generated response length: ${responseText.length}');
        return responseText;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return 'Request timed out. The model might be processing a complex prompt.';
    } on SocketException catch (e) {
      print('🔌 Socket error: $e');
      return 'Cannot reach the server. Check network connection.';
    } catch (e) {
      print('Other error: $e');
      return 'Error: ${e.toString()}';
    }
  }

  String _buildMedicalPrompt(String userInput) {
    // Simplified prompt to reduce processing time
    return '''You are a helpful medical assistant. Provide brief, informative responses about health topics.

Guidelines:
- Always remind users to consult healthcare professionals for serious concerns
- Provide general information, not specific medical diagnoses
- Keep responses concise

User question: $userInput

Response:''';
  }

  Future<bool> checkConnection() async {
    try {
      print('Testing connection to: $baseUrl/api/tags');
      final response = await http.get(
        Uri.parse('$baseUrl/api/tags'),
      ).timeout(const Duration(seconds: 5));
      
      print('Connection test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}