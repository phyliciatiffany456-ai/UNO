import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'models/story_seen_store.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String? configProblem = _validateSupabaseConfig(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );

  if (configProblem != null) {
    runApp(_MissingConfigApp(message: configProblem));
    return;
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabasePublishableKey,
  );
  await StorySeenStore.init();

  runApp(const UnoApp());
}

String? _validateSupabaseConfig({
  required String url,
  required String publishableKey,
}) {
  if (url.isEmpty || publishableKey.isEmpty) {
    return 'Supabase config belum diisi.\n\n'
        'Isi file .vscode/supabase.local.json lalu jalankan ulang app.';
  }

  final Uri? parsedUrl = Uri.tryParse(url);
  final bool validHttpUrl =
      parsedUrl != null &&
      (parsedUrl.scheme == 'http' || parsedUrl.scheme == 'https') &&
      parsedUrl.host.isNotEmpty;

  if (!validHttpUrl) {
    return 'SUPABASE_URL tidak valid.\n\n'
        'Gunakan format seperti:\n'
        'https://PROJECT-REF.supabase.co';
  }

  if (publishableKey.length < 20) {
    return 'SUPABASE_PUBLISHABLE_KEY terlihat tidak valid.\n\n'
        'Pastikan yang dipakai adalah anon/publishable key dari project Supabase.';
  }

  return null;
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F1013),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                '$message\n\n'
                'Contoh file:\n'
                '.vscode/supabase.local.json',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
