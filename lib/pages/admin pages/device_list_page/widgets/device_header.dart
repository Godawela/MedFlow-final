import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class DevicesHeader extends StatelessWidget {
  final int deviceCount;

  const DevicesHeader({super.key, required this.deviceCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Available Devices',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$deviceCount devices',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
