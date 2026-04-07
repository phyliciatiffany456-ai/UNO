import 'package:flutter/material.dart';

import '../pages/apply_page.dart';
import '../pages/community_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String apply = '/apply';
  static const String community = '/community';
  static const String profile = '/profile';
  static bool _isNavigating = false;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute<void>(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      case apply:
        return MaterialPageRoute<void>(
          builder: (_) => const ApplyPage(),
          settings: settings,
        );
      case community:
        return MaterialPageRoute<void>(
          builder: (_) => const CommunityPage(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case home:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }

  static void _safeNavigate(BuildContext context, String routeName) {
    if (_isNavigating || !context.mounted) return;

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == routeName) return;

    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _isNavigating = false;
        return;
      }

      final Widget page = _pageFor(routeName);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => page,
          settings: RouteSettings(name: routeName),
        ),
        (Route<dynamic> route) => false,
      );
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        _isNavigating = false;
      });
    });
  }

  static Widget _pageFor(String routeName) {
    switch (routeName) {
      case login:
        return const LoginPage();
      case register:
        return const RegisterPage();
      case forgotPassword:
        return const ForgotPasswordPage();
      case apply:
        return const ApplyPage();
      case community:
        return const CommunityPage();
      case profile:
        return const ProfilePage();
      case home:
      default:
        return const HomePage();
    }
  }

  static void goHome(BuildContext context) => _safeNavigate(context, home);

  static void goLogin(BuildContext context) => _safeNavigate(context, login);

  static void goRegister(BuildContext context) =>
      _safeNavigate(context, register);

  static void goForgotPassword(BuildContext context) =>
      _safeNavigate(context, forgotPassword);

  static void goApply(BuildContext context) => _safeNavigate(context, apply);

  static void goCommunity(BuildContext context) =>
      _safeNavigate(context, community);

  static void goProfile(BuildContext context) =>
      _safeNavigate(context, profile);
}
