
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/pages/admin%20pages/machine_admin.dart';
import 'package:med/pages/admin%20pages/symptom_admin.dart';
import 'package:med/pages/user%20pages/machine.dart';
import 'package:med/pages/user%20pages/symptom.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

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
    return Column(
      children: [
        buildActionButton('Machines', () async {
          final role = await fetchUserRole(); 

          if (role == 'Admin') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MachinePageAdmin()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MachinePage()),
            );
          }
        }),
        const SizedBox(height: 20),
           buildActionButton('Symptoms', () async {
          final role = await fetchUserRole(); 

          if (role == 'Admin') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SymptomPageAdmin()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SymptomPage()),
            );
          }
        }),
      ],
    );
  }

  Widget buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CE6F6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
      ),
    );
  }

}
