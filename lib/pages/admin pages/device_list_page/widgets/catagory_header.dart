import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/catagory_icon.dart';

class CategoryHeader extends StatelessWidget {
  final String category;
  final String? imageUrl;
  final IconData Function(String) getDeviceIcon;

  const CategoryHeader({
    Key? key,
    required this.category,
    this.imageUrl,
    required this.getDeviceIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CategoryIcon(
          imageUrl: imageUrl,
          category: category,
          getDeviceIcon: getDeviceIcon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
