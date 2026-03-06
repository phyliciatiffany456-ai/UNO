import 'package:flutter/material.dart';

import '../pages/apply_page.dart';
import '../pages/community_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String apply = '/apply';
  static const String community = '/community';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case apply:
        return MaterialPageRoute<void>(builder: (_) => const ApplyPage());
      case community:
        return MaterialPageRoute<void>(builder: (_) => const CommunityPage());
      case profile:
        return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
      case home:
      default:
        return MaterialPageRoute<void>(builder: (_) => const HomePage());
    }
  }

  static void goHome(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(home);

  static void goApply(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(apply);

  static void goCommunity(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(community);

  static void goProfile(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(profile);
}
