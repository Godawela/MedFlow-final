import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/widgets/auth_form.dart';
import 'package:med/widgets/auth_header.dart';
import 'package:med/widgets/sign_up_prompt.dart';
import 'package:med/widgets/social_login_button.dart';
import 'package:med/routes/router.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 🔹 Send user data to your backend MongoDB
  Future<void> sendToMongoDB(String uid, String? email, String? name) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': uid,
          'email': email,
          'name': name,
          'role': 'student', // default role
        }),
      );

      if (response.statusCode == 200) {
        print('Google user data saved to MongoDB');
      } else {
        print('Failed to save to MongoDB: ${response.body}');
      }
    } catch (e) {
      print('MongoDB error: $e');
    }
  }

  // 🔹 Google Sign-In Handler
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null && context.mounted) {
        await sendToMongoDB(user.uid, user.email, user.displayName);
        AutoRouter.of(context).replace(const HomeRoute());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              children: [
                const AuthHeader(),
                const SizedBox(height: 26),
                const AuthForm(),
                const SizedBox(height: 20),
                const Text(
                  'Or continue with social account',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 45),
                GestureDetector(
                  onTap: signInWithGoogle,
                  child: const SocialLoginButton(
                    icon: FontAwesomeIcons.google,
                    text: 'Google',
                    iconColor: Colors.red,
                  ),
                ),
                const SizedBox(height: 31),
                const SignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
