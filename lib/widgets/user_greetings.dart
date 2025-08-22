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
  Future.delayed(Duration.zero, fetchUserRole);
}


  Future<void> fetchUserRole() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('Current user: $user');
    
    final uid = user?.uid;
    debugPrint('UID: $uid');

    if (uid == null) {
      debugPrint('UID is null — Firebase not ready yet?');
      setState(() => role = 'Guest');
      return;
    }

    final url = 'https://medflow-phi.vercel.app/api/users/$uid/role';
    debugPrint('Requesting: $url');

    final response = await http.get(Uri.parse(url));
    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        role = data['role'] ?? 'Student';
      });
    } else {
      setState(() => role = 'Student');
    }
  } catch (e) {
    debugPrint('Exception: $e');
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
