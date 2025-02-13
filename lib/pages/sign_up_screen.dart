import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med/widgets/auth_form.dart';
import 'package:med/widgets/auth_header.dart';
import 'package:med/widgets/sign_up_prompt.dart';
import 'package:med/widgets/social_login_button.dart';

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
    @override
    Widget build(BuildContext context) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                children: [
                  AuthHeader(),
                  SizedBox(height: 26),
                  AuthForm(),
                  SizedBox(height: 20),
                  Text(
                    'Or continue with social account',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 45),
                  SocialLoginButton(
                    icon: FontAwesomeIcons.google, // Google icon
                    text: 'Google',
                  ),
                  SizedBox(height: 31),
                  SignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

