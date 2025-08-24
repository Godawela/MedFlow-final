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
 String? userName;
  String? email;
  String? role;
    bool isLoading = true;

  String _capitalize(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

   Future<void> fetchUserData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    try {
      final response = await http.get(Uri.parse('https://medflow-phi.vercel.app/api/users/$uid'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = _capitalize(data['name']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

 @override
void initState() {
  super.initState();
  Future.delayed(Duration.zero, fetchUserData);
}



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          userName != null ? 'Hi! $userName' : 'Loading...',
          style: GoogleFonts.goblinOne(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
