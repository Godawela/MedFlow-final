import 'package:flutter/material.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        text: "Already have an account? ",
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: 'Sign Up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}