import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/catagory_action_button.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/catagory_header.dart';

class CategoryHeaderCard extends StatelessWidget {
  final String category;
  final String? categoryDescription;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final IconData Function(String) getDeviceIcon;

  const CategoryHeaderCard({
    super.key,
    required this.category,
    this.categoryDescription,
    this.imageUrl,
    required this.onEdit,
    required this.onDelete,
    required this.getDeviceIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryHeader(
            category: category,
            imageUrl: imageUrl,
            getDeviceIcon: getDeviceIcon,
          ),
          if (categoryDescription != null) ...[
            const SizedBox(height: 16),
            Text(
              categoryDescription!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.9),
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          CategoryActionButtons(
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
