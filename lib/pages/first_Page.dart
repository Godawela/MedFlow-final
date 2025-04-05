import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med/pages/machine.dart';
import 'package:med/pages/symptom.dart';
import 'package:med/widgets/menu_items.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              _buildMenuItem(context, 'Settings', Icons.settings),
              _buildMenuItem(context, 'Profile', Icons.person),
              _buildMenuItem(context, 'Notes', Icons.note),
              _buildMenuItem(context, 'Chatbot', Icons.chat),
              _buildMenuItem(context, 'Draw with me', Icons.brush),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.only(bottom: 320),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(top: 13),
                  child: Column(
                    children: [
                      UserGreeting(),
                      SizedBox(height: 44),
                      Text(
                        'Please select one to proceed',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inter',
                        ),
                      ),
                      ActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      BuildContext context, String title, IconData icon) {
    return PopupMenuItem<String>(
      value: title,
      onTap: () {
        // Add a slight delay to avoid navigation issues with popup menu
        Future.delayed(const Duration(milliseconds: 10), () {
          MenuItems.handleMenuItemTap(context, title);
        });
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class UserGreeting extends StatelessWidget {
  const UserGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          'Hi! User',
          style: GoogleFonts.goblinOne(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButton('Machines', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MachinePage()),
          );
        }),
        const SizedBox(height: 20),
        _buildActionButton('Symptom', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SymptomPage()),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CE6F6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
