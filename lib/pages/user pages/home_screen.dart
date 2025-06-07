import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/widgets/actions_buttons.dart';
import 'package:med/widgets/appbar.dart';
import 'package:med/widgets/user_greetings.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // CurvedAppBar at the top
          const CurvedAppBar(
            title: 'Welcome',
            isProfileAvailable: false,
            showIcon: true,
            isBack: false, // Changed to false since this is home screen
          ),
          
          // Main content below the app bar with negative margin to overlap
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -40), // Move content up by 40 pixels to overlap with curve
              child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  const CircleAvatar(
                    radius: 33.5,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Greeting
                 const UserGreeting(),
                  
                  const SizedBox(height: 44),
                  
                  // Instructions text
                  const Text(
                    'Please select one to proceed',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  const ActionButtons(),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add your navigation or dialog logic here
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('How to Use This'),
                          content: const Text('Instructions on how to use this app go here.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('How to use this'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
      )],
      ),
    );
  }
}