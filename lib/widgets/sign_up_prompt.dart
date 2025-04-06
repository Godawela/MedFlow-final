import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:med/routes/router.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AutoRouter.of(context).replace(const LoginRoute());
      };

    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: 'Sign In',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            recognizer: _tapGestureRecognizer,
          ),
        ],
      )
    );
  }
}