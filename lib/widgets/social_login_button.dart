import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final VoidCallback? onPressed; // 👈 New parameter

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.black,
    this.onPressed, // 👈 Assign it here
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // 👈 Make button tappable
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(width: 11),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
