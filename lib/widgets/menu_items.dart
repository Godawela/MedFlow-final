import 'package:flutter/material.dart';
import 'package:med/pages/draw.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with your widget tree
  }

  // Make this static so it can be called without an instance
  static void handleMenuItemTap(BuildContext context, String item) {
    switch (item) {
      case 'Settings':
        // Navigate to settings page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings page coming soon')),
        );
        break;
      case 'Profile':
        // Navigate to profile page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile page coming soon')),
        );
        break;
      case 'Notes':
        // Navigate to notes page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes page coming soon')),
        );
        break;
      case 'Chatbot':
        // Navigate to chatbot page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chatbot page coming soon')),
        );
        break;
      case 'Draw with me':
        // Navigate to drawing page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DrawingApp()),
        );
        break;
    }
  }
}