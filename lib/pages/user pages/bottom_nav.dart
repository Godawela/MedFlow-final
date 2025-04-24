import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med/data/providers.dart';
import 'package:med/pages/admin%20pages/home_screen.dart';
import 'package:med/pages/user%20pages/home_screen.dart';
import 'package:med/pages/user%20pages/note_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


@RoutePage()
class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider); // Get the current index from the provider
    final navigationNotifier = ref.read(navigationProvider.notifier); // Get the notifier to update the index

    // List of pages to navigate to
    final List<Widget> pages = [
      FutureBuilder<String?>(
        future: SharedPreferences.getInstance().then((prefs) => prefs.getString('selectedRole')),
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == 'Student') {
        return const HomeScreen();
          } else {
        return const HomeScreenAdmin();
          }
        },
      ),
      const NotePage(),
      const HomeScreenAdmin(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blueGrey,
        buttonBackgroundColor: Colors.lightBlue,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 200),
        height: MediaQuery.of(context).size.height * 0.075,
        items: const [
          Icon(Icons.home_filled, color:  Colors.white),
          Icon(Icons.person, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],

        // Set the current index to the selected index
        index: currentIndex,
        onTap: (index) {
          navigationNotifier.setIndex(index);
        },
      ),
    );
  }
}