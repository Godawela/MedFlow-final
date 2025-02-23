import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 9),
        CircleAvatar(
          radius: 33.5,
          backgroundImage: AssetImage('assets/images/logo.png'),
        ),
        SizedBox(height: 10),
        Text(
          'Join MedFlow',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Goblin One',
            color: Colors.black,
          ),
        ),
        SizedBox(height: 13),
        Text(
          'You can easily sign up, explore and share',
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}


