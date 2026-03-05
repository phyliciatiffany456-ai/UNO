import 'package:flutter/material.dart';

import 'pages/home_page.dart';

class UnoApp extends StatelessWidget {
  const UnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNO LinkedIn Social',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F1013),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
