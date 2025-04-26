import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String? token = await userCredential.user!.getIdToken();
        String uid = userCredential.user!.uid;

        // Store token and uid using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token ?? '');
        await prefs.setString('uid', uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in successful! Token and UID saved.'),
            backgroundColor: Colors.green,
          ),
        );
        AutoRouter.of(context).push(const BottomNavigationRoute());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Initialize Google Sign-In
      GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the Google Sign-In flow
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Obtain authentication details
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase Auth
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        String? token = await userCredential.user!.getIdToken();
        String uid = userCredential.user!.uid;

        // Store token and uid using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token ?? '');
        await prefs.setString('uid', uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful! Token and UID saved.'),
            backgroundColor: Colors.green,
          ),
        );
        AutoRouter.of(context).push(const HomeRoute());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 11),
                const Center(
                  child: CircleAvatar(
                  radius: 33.5,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
                const Center(
                  child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontFamily: 'Goblin One',
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                  'Sign in to your account',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    fontSize: 16,
                  ),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
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
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(15, 121, 134, 1),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            AutoRouter.of(context)
                                .replace(const ForgotPasswordRoute());
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                const Center(
                  child: Text(
                    'Or continue with social account',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                SocialLoginButton(
                  icon: FontAwesomeIcons.google,
                  text: 'Google',
                  iconColor: Colors.red,
                  onPressed: handleGoogleSignIn, // Trigger Google Sign-In
                ),
                const SizedBox(height: 31),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 16),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
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
                const SizedBox(height: 71),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
