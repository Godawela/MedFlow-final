import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/widgets/actions_buttons.dart';
import 'package:med/widgets/menu_items.dart';
import 'package:med/widgets/user_greetings.dart';
// import 'package:medflownew/pages/machine.dart';
// import 'package:medflownew/pages/symptom.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.only(bottom: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 const SizedBox(height: 16),
                Padding(
                  padding:  const EdgeInsets.only(top: 13),
                  child: Column(
                    children:  [
                      const UserGreeting(),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                              return const MenuItems();
                              },
                            );
                            },
                        ),
                      ),
                        
                      
                      const SizedBox(height: 44),
                      const Text(
                        'Please select one to proceed',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const ActionButtons(),
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
}




