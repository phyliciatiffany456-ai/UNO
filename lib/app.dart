import 'package:flutter/material.dart';

import 'navigation/app_routes.dart';

class UnoApp extends StatelessWidget {
  const UnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNO LinkedIn Social',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F1013),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1013),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white, size: 20),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.35,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
