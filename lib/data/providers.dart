import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier to manage navigation index
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0); // Initial index

  void setIndex(int index) {
    state = index;
  }
}

// Riverpod Provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, int>(
  (ref) => NavigationNotifier(),
);