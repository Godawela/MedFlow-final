import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/widgets/actions_buttons.dart';
import 'package:med/widgets/menu_items.dart';
import 'package:med/widgets/user_greetings.dart';
// import 'package:medflownew/pages/machine.dart';
// import 'package:medflownew/pages/symptom.dart';

@RoutePage()
class HomeScreenAdmin extends StatelessWidget {
  const HomeScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  padding:   EdgeInsets.only(top: 13),
                  child: Column(
                    children:  [
                       Center(
                  child: CircleAvatar(
                  radius: 33.5,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
                       UserGreeting(),
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: IconButton(
                      //       icon: const Icon(Icons.menu),
                      //       onPressed: () {
                      //       showModalBottomSheet(
                      //         context: context,
                      //         builder: (BuildContext context) {
                      //         return const MenuItems();
                      //         },
                      //       );
                      //       },
                      //   ),
                      // ),
                        
                      
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
}




