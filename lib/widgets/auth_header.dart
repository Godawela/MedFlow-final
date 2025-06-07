import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 9),
        Center(
          child: CircleAvatar(
        radius: 33.5,
        backgroundImage: AssetImage('assets/images/logo.png'),
        backgroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
        'Join MedFlow',
        style: TextStyle(
          fontSize: 30,
          fontFamily: 'Goblin One',
          color: Colors.black,
        ),
          ),
        ),
        SizedBox(height: 13),
        Center(
          child: Text(
        'You can easily sign up, explore and share',
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          fontSize: 16,
        ),
          ),
        ),
      ],
      
    );
  }
}


