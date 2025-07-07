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
    print('Current user: $user');
    
    final uid = user?.uid;
    print('UID: $uid');

    if (uid == null) {
      print('UID is null — Firebase not ready yet?');
      setState(() => role = 'Guest');
      return;
    }

    final url = 'https://medflow-phi.vercel.app/api/users/$uid/role';
    print('Requesting: $url');

    final response = await http.get(Uri.parse(url));
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        role = data['role'] ?? 'student';
      });
    } else {
      setState(() => role = 'Unknown');
    }
  } catch (e) {
    print('Exception: $e');
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
