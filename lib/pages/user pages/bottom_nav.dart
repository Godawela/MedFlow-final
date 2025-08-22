import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med/data/providers.dart';
import 'package:med/pages/admin%20pages/user_details.dart';
import 'package:med/pages/user%20pages/chat_bot.dart';
import 'package:med/pages/user%20pages/home_screen.dart';
import 'package:med/pages/user%20pages/note_page/note_page.dart';
import 'package:med/pages/user%20pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class BottomNavigation extends ConsumerWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider); // Get the current index from the provider
    final navigationNotifier = ref.read(navigationProvider.notifier); // Get the notifier to update the index

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final prefs = snapshot.data!;
        final userRole = prefs.getString('userRole');
        // List of pages to navigate to
        final List<Widget> pages = [
          const HomeScreen(),
          const ProfilePage(),
          const NotePage(),
          userRole == 'Admin'
              ? const UserManagementScreen()
              : const ChatBotPage(),
        ];

        return Scaffold(
          extendBody: true,
          body: pages[currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            color: const Color(0xFF8E2DE2), // Using the lighter gradient color
            buttonBackgroundColor: const Color(0xFF4B00E0), // Using the darker gradient color
            backgroundColor: Colors.transparent,
            animationDuration: const Duration(milliseconds: 200),
            height: MediaQuery.of(context).size.height * 0.075,
            items:  [
             const Icon(Icons.home_filled, color: Colors.white),
             const Icon(Icons.person, color: Colors.white),
             const Icon(Icons.note, color: Colors.white),
              userRole == 'Admin'
                  ? const Icon(Icons.admin_panel_settings, color: Colors.white)
                  : const Icon(Icons.chat, color: Colors.white),
            ],
            // Set the current index to the selected index
            index: currentIndex,
            onTap: (index) {
              navigationNotifier.setIndex(index);
            },
          ),
        );
      },
    );
  }
}