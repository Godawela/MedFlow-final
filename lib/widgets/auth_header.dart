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
          backgroundImage: NetworkImage('https://cdn.builder.io/api/v1/image/assets/TEMP/1a4d6a25074baaad02b85df12e5380b4ef368b38d46550453b4487519d8d76b9?placeholderIfAbsent=true&apiKey=f815b67fc3874cb68d73fa67ce14b3f4'),
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


