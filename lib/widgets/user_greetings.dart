import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGreeting extends StatelessWidget {
  const UserGreeting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          'Hi! User',
          style: GoogleFonts.goblinOne(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}