import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/routes/router.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem(context, 'Settings', Icons.settings),
          _buildMenuItem(context, 'Profile', Icons.person),
          _buildMenuItem(context, 'Notes', Icons.note),
          _buildMenuItem(context, 'Chatbot', Icons.chat),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        handleMenuItemTap(context, title);
      },
    );
  }

  static void handleMenuItemTap(BuildContext context, String item) {
    switch (item) {
      case 'Settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings page coming soon')),
        );
        break;
      case 'Profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile page coming soon')),
        );
        break;
      case 'Notes':
        context.router.push(const NoteRoute());
        break;
      case 'Chatbot':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chatbot page coming soon')),
        );
        break;
    
    }
  }
}
