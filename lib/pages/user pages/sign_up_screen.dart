
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/widgets/auth_form.dart';
import 'package:med/widgets/auth_header.dart';
import 'package:med/widgets/sign_up_prompt.dart';
import 'package:med/widgets/social_login_button.dart';
import 'package:med/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
    bool isLoading = false;
      final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<bool> checkUserVerified(String uid) async {
    try {
      final url = Uri.parse('https://medflow-phi.vercel.app/api/users/$uid');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['verified'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking verification status: $e');
      return false;
    }
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      final url = Uri.parse('https://medflow-phi.vercel.app/api/users/$uid');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      return false;
    }
  }

  // Send user data to MongoDB
  Future<void> createUserInBackend(User user) async {
    try {
      final url = Uri.parse('https://medflow-phi.vercel.app/api/users');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'Google User',
          'role': 'student',
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Error creating user in backend: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating user in backend: $e');
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Google Sign-In Handler
  Future<void> signInWithGoogle() async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        String? token = await userCredential.user!.getIdToken();
        String uid = userCredential.user!.uid;

        // Check if user exists in backend
        bool userExists = await checkUserExists(uid);
        
        if (!userExists) {
          // Create user in backend first
          await createUserInBackend(userCredential.user!);
            // Sign out after creating unverified user
        await googleSignIn.signOut();
        await _auth.signOut();
          _showSnackBar(
            'Account created! Please wait for admin approval before you can log in.',
            Colors.orange.shade600,
          );
          return;
        }

        // Check verification status
        bool isVerified = await checkUserVerified(uid);
        if (!isVerified) {
            // Sign out the unverified user so they can try different email
        await googleSignIn.signOut();
        await _auth.signOut();
          _showSnackBar(
            'Your account is not verified by admin yet. Please wait for approval.',
            Colors.red.shade400,
          );
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token ?? '');
        await prefs.setString('uid', uid);

        _showSnackBar('Google Sign-In successful!', Colors.green.shade600);
        
        if (mounted) {
          AutoRouter.of(context).push(const BottomNavigationRoute());
        }
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red.shade400);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AuthHeader(),
                const SizedBox(height: 32),
                const AuthForm(),
                const SizedBox(height: 24),
                _buildDividerWithText('or continue with'),
                const SizedBox(height: 16),
                _buildSocialButtons(),
                const SizedBox(height: 24),
                const SignUpPrompt(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SocialLoginButton(
          icon: FontAwesomeIcons.google,
          text: 'Continue with Google',
          iconColor: Colors.red,
          onPressed: signInWithGoogle,
        ),
      ],
    );
  }
}