import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:med/routes/router.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
        children: [
          const TextSpan(text: "Already have an account? "),
          TextSpan(
            text: 'Sign In',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => AutoRouter.of(context).replace(const LoginRoute()),
          ),
        ],
      ),
    );
  }
}