// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:med/routes/router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final String _selectedRole = 'student'; 

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

      // Show success message instead of navigating directly
      _showSuccessDialog();
      
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      showErrorSnackBar('Error during sign-up: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to send data to your MongoDB backend API
  Future<void> sendToMongoDB(String uid, String email, String name, String role) async {
    final url = Uri.parse('https://medflow-phi.vercel.app/api/users');

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
        debugPrint('User data saved to MongoDB successfully');
      } else {
        debugPrint('Error saving data to MongoDB: ${response.body}');
        showErrorSnackBar('Error saving data to MongoDB');
      }
    } catch (e) {
      debugPrint('Error while sending data to MongoDB: $e');
      showErrorSnackBar('Error sending data to MongoDB');
    }
  }

  // Show success dialog after registration
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Registration Successful!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Your account has been created successfully. Please wait for admin approval before you can log in. You will receive an email confirmation once approved.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                AutoRouter.of(context).replace(const LoginRoute());
              },
              child: Text(
                'Go to Login',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple.shade600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show error messages in a SnackBar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildSignUpButton(theme),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

 Widget _buildSignUpButton(ThemeData theme) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: isLoading ? null : _handleSignUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    ),
  );
}

  void _handleSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      showErrorSnackBar('Please fill all fields');
      return;
    }
    
    signUpUser(email, password, name, _selectedRole);
  }
}