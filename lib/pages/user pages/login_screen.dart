import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:med/routes/router.dart';
import 'package:med/widgets/social_login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
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

  Future<void> handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red.shade400);
      return;
    }

    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        String? token = await userCredential.user!.getIdToken();
        String uid = userCredential.user!.uid;

        // Check verification status from backend before allowing login
        bool isVerified = await checkUserVerified(uid);
        if (!isVerified) {
          _showSnackBar(
            'Your account is not verified by admin yet. Please wait for approval.',
            Colors.red.shade400,
          );
          return; // stop login flow
        }

        // If verified --> proceed with login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token ?? '');
        await prefs.setString('uid', uid);

        _showSnackBar('Sign-in successful!', Colors.green.shade600);

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

  Future<void> handleGoogleSignIn() async {
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
          _showSnackBar(
            'Account created! Please wait for admin approval before you can log in.',
            Colors.orange.shade600,
          );
          return;
        }

        // Check verification status
        bool isVerified = await checkUserVerified(uid);
        if (!isVerified) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Sign in to continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                              hintText: 'Enter your email',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(
                                Icons.email_rounded,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                              hintText: 'Enter your password',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_rounded,
                                color: Colors.grey.shade600,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                AutoRouter.of(context)
                                    .replace(const ForgotPasswordRoute());
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  color: Colors.deepPurple.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SocialLoginButton(
                      icon: FontAwesomeIcons.google,
                      text: 'Continue with Google',
                      iconColor: Colors.red.shade600,
                      onPressed: handleGoogleSignIn,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: GoogleFonts.inter(
                                color: Colors.deepPurple.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  AutoRouter.of(context)
                                      .replace(const SignUpRoute());
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}