import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:med/routes/router.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AutoRouter.of(context).replace(const LoginRoute());
      };

    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: const TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: 'Sign In',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            recognizer: tapGestureRecognizer,
          ),
        ],
      )
    );
  }
}