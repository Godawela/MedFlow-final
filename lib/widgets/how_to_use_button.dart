import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HowToUseButton extends StatelessWidget {
  const HowToUseButton({super.key});
  Future<String?> fetchUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      debugPrint("objects $uid");

      if (uid == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('https://medflow-phi.vercel.app/api/users/$uid/role'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("role how to use: ${data['role']}"); // Debugging line to check role
        return data['role'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
      return null;
    }
  }

 @override
Widget build(BuildContext context) {
  return FutureBuilder<String?>(
    future: fetchUserRole(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator(); // or SizedBox.shrink() if you want to hide during load
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error fetching role'));
      }

      final role = snapshot.data;

      return ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4B00E0), Color(0xFF8E2DE2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'How to Use This App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (role == "admin") ...[
                      const Text(
                        'Welcome to our medical app! Here you can:\n\n'
                        '• Add,Update or Delete helpful resources\n'
                        '• Supports video link and image uploading\n'
                        '• Take notes\n'
                        '• Chat with our AI chat bot Ollama\n\n'
                        'Select any option from the main screen to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ] else ...[
                      const Text(
                        'Welcome to our medical app! Here you can:\n\n'
                        '• Access helpful resources video links and images\n'
                        '• Chat with our AI chat bot Ollama\n'
                        '• Take notes about devices and symptoms\n\n'
                        'Select any option from the main screen to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4B00E0), Color(0xFF8E2DE2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Got it!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.help_outline,
          color: Color(0xFF8E2DE2),
        ),
        label: const Text(
          'How to use this app?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8E2DE2),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    },
  );
}
}