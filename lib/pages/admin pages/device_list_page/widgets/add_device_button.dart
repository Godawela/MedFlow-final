
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDeviceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddDeviceButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.deepPurple.shade500,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Add Device',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}