// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    DeviceListRoute.name: (routeData) {
      final args = routeData.argsAs<DeviceListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeviceListPage(
          key: args.key,
          category: args.category,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    NoteRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotePage(),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpScreen(),
      );
    },
  };
}

/// generated route for
/// [DeviceListPage]
class DeviceListRoute extends PageRouteInfo<DeviceListRouteArgs> {
  DeviceListRoute({
    Key? key,
    required int category,
    List<PageRouteInfo>? children,
  }) : super(
          DeviceListRoute.name,
          args: DeviceListRouteArgs(
            key: key,
            category: category,
          ),
          initialChildren: children,
        );

  static const String name = 'DeviceListRoute';

  static const PageInfo<DeviceListRouteArgs> page =
      PageInfo<DeviceListRouteArgs>(name);
}

class DeviceListRouteArgs {
  const DeviceListRouteArgs({
    this.key,
    required this.category,
  });

  final Key? key;

  final int category;

  @override
  String toString() {
    return 'DeviceListRouteArgs{key: $key, category: $category}';
  }
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotePage]
class NoteRoute extends PageRouteInfo<void> {
  const NoteRoute({List<PageRouteInfo>? children})
      : super(
          NoteRoute.name,
          initialChildren: children,
        );

  static const String name = 'NoteRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
