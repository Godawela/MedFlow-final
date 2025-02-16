import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/pages/device_page.dart';
import 'package:med/pages/home_screen.dart';
import 'package:med/pages/login_screen.dart';
import 'package:med/pages/machine.dart';
import 'package:med/pages/sign_up_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: MachineRoute.page)
  ];
}
