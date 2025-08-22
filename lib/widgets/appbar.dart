import 'package:flutter/material.dart';

class CurvedAppBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool isProfileAvailable;
  final ImageProvider? profileImage;
  final bool? leadingWidget;
  final VoidCallback? leadingCallback;
  final bool showIcon;
  final Color? backgroundColor;
  final bool? isBack;
  final VoidCallback? backFunction;
  final List<PopupMenuButton<String>> actions;

  const CurvedAppBar({
    super.key,
    this.title,
    this.subtitle,
    required this.isProfileAvailable,
    this.profileImage,
    this.leadingWidget,
    this.leadingCallback,
    this.showIcon = true,
    this.backgroundColor,
    this.isBack,
    this.backFunction, 
    this.actions = const [],
  }) : assert(
          isProfileAvailable == false || profileImage != null,
          'If isProfileAvailable is true, you must provide profileImage',
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          // Curved Background
          ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              height: 170,
              decoration:  BoxDecoration(
                gradient: backgroundColor == null
                    ?  const LinearGradient(
                        colors: [Color(0xFF4B00E0), Color(0xFF8E2DE2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                // color: Colors.purple,
              ),
            ),
          ),

          // Foreground content
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button (optional)
                if (isBack == true)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                if (isBack == true) const SizedBox(width: 8),

                // Profile Picture (only if available)
                if (isProfileAvailable)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImage,
                  ),

                if (isProfileAvailable) const SizedBox(width: 16),

                // Title and Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        title!,
                        style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),

                const Spacer(),

                // Right logo (optional)
                if (showIcon)
                  ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png', 
                    width: 70,
                    height:70,
                    fit: BoxFit.cover,
                  ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const curveHeight = 40.0;

    // Start at top-left
    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    // Bottom-left inward curve
    path.quadraticBezierTo(
      0, size.height - curveHeight,          // control point
      curveHeight, size.height - curveHeight // end point
    );

    // Straight bottom edge
    path.lineTo(size.width - curveHeight, size.height - curveHeight);

    // Bottom-right inward curve
    path.quadraticBezierTo(
      size.width, size.height - curveHeight,             // control point
      size.width, size.height                            // end point
    );

    // Right edge up
    path.lineTo(size.width, 0);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
