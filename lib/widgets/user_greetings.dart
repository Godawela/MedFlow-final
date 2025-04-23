import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class UserGreeting extends StatefulWidget {
  const UserGreeting({super.key});

  @override
  State<UserGreeting> createState() => _UserGreetingState();
}

class _UserGreetingState extends State<UserGreeting> {
  String? role;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => role = 'Guest');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/$uid/role'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          role = data['role'] ?? 'User';
        });
      } else {
        setState(() => role = 'Unknown');
      }
    } catch (e) {
      setState(() => role = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          role != null ? 'Hi! $role' : 'Loading...',
          style: GoogleFonts.goblinOne(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
