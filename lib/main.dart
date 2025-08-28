import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med/routes/router.dart';
import 'package:med/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
      await NotificationService().initialize();

    runApp( const ProviderScope( child: MyApp(),));
  
 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppRouter router = AppRouter();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router.config(),
    );
  }
}
