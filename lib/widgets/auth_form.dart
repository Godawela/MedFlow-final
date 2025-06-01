import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:med/routes/router.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  String _selectedRole = 'student'; // default role (you can hard-code the role if needed)

  // Function to handle user sign-up with Firebase Authentication
  Future<void> signUpUser(String email, String password, String name, String role) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Create user in Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send additional user data (name + role) to MongoDB
      await sendToMongoDB(userCredential.user!.uid, email, name, role);

      // Navigate to bottom nav bar if sign-up is successful
      AutoRouter.of(context).push(const BottomNavigationRoute());
    } catch (e) {
      print('Error during sign-up: $e');
      showErrorSnackBar('Error during sign-up: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to send data to your MongoDB backend API
  Future<void> sendToMongoDB(String uid, String email, String name, String role) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/users'); // Change this to your backend endpoint

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'email': email,
          'name': name,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        print('User data saved to MongoDB successfully');
      } else {
        print('Error saving data to MongoDB: ${response.body}');
        showErrorSnackBar('Error saving data to MongoDB');
      }
    } catch (e) {
      print('Error while sending data to MongoDB: $e');
      showErrorSnackBar('Error sending data to MongoDB');
    }
  }

  // Function to show error messages in a SnackBar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromRGBO(217, 217, 217, 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Removed the role selection dropdown

            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();
                        String name = _nameController.text.trim();
                        signUpUser(email, password, name, _selectedRole);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(15, 121, 134, 1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
