import 'package:auto_route/auto_route.dart';
import 'package:med/pages/admin%20pages/add_category.dart';
import 'package:med/pages/admin%20pages/add_device_details.dart';
import 'package:med/pages/admin%20pages/add_symptom.dart';
import 'package:med/pages/admin%20pages/question_management_page.dart';
import 'package:med/pages/admin%20pages/user_details.dart';
import 'package:med/pages/user%20pages/bottom_nav.dart';
import 'package:med/pages/user%20pages/forget_password.dart';
import 'package:med/pages/user%20pages/home_screen.dart';
import 'package:med/pages/user%20pages/login_screen.dart';
import 'package:med/pages/user%20pages/note_page/note_page.dart';
import 'package:med/pages/user%20pages/profile_page.dart';
import 'package:med/pages/user%20pages/question_view_page.dart';
import 'package:med/pages/user%20pages/sign_up_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: NoteRoute.page),
    AutoRoute(page: BottomNavigationRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),
    AutoRoute(page: AddCategoryRoute.page),
    AutoRoute(page: AddDeviceRoute.page),
    AutoRoute(page: AddSymptomRoute.page),
    AutoRoute(page: QuestionsRoute.page),
    AutoRoute(page: UserManagementRoute.page),
    AutoRoute(page: StudentQuestionsRoute.page)
  ];
}
