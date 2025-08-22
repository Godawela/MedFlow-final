import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final IconData Function(String) getDeviceIcon;

  const CategoryIcon({
    super.key,
    this.imageUrl,
    required this.category,
    required this.getDeviceIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return _buildIconFallback();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  );
                },
              )
            : _buildIconFallback(),
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        getDeviceIcon(category),
        size: 28,
        color: Colors.white,
      ),
    );
  }
}