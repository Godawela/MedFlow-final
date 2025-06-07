import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/routes/router.dart';
import 'package:med/widgets/appbar.dart';
import 'package:med/widgets/user_greetings.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? email;
  String? role;
  bool isLoading = true;
  bool isEditingName = false;

  final TextEditingController nameController = TextEditingController();

  String _capitalize(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/users/$uid'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = _capitalize(data['name']);
          email = data['email'];
          role = _capitalize(data['role']);
          nameController.text = userName!;
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

  Future<void> updateUserData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final Map<String, dynamic> updatedData = {
      'name': nameController.text.trim(),
    };

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/users/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        final updated = json.decode(response.body);
        setState(() {
          userName = _capitalize(updated['name']);
          nameController.text = userName!;
          isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user data: $e')),
      );
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    context.router.navigate(LoginRoute()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
    children: [
    const  CurvedAppBar(
        title: 'Profile',
        isProfileAvailable: false,
        showIcon: true,
        isBack: false,
      ),
      Expanded(
      child: isLoading
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 33.5,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            const UserGreeting(),
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            readOnly: !isEditingName,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person , color: Colors.blue),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(isEditingName ? Icons.check : Icons.edit , color: Colors.blue),
                          onPressed: () {
                            if (isEditingName) {
                              updateUserData();
                            } else {
                              setState(() {
                                isEditingName = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(email ?? '', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge, color: Colors.blue),
                      title: Text(role ?? '', style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: logOut,
                      icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Log Out', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

        ),
    ],
      ),);
  }
}
