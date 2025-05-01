import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/pages/admin%20pages/machine_admin.dart';
import 'package:med/pages/admin%20pages/symptom_admin.dart';
import 'package:med/pages/user%20pages/machine.dart';
import 'package:med/pages/user%20pages/symptom.dart';
import 'package:med/widgets/buildActionButton.dart';
import 'package:shared_preferences/shared_preferences.dart'; // keep this for uid

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  Future<String?> fetchUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid'); 

      print("objects $uid"); 

      if (uid == null) {
        return null; 
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/$uid/role'), 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['role']; 
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching role: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildActionButton('Machines', () async {
          final role = await fetchUserRole(); 

          if (role == 'admin') {
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
           buildActionButton('Symptom', () async {
          final role = await fetchUserRole(); 

          if (role == 'admin') {
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
}
