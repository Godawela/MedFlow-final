import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SymptomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const SymptomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.healing,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CE6F6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
