import 'package:flutter/material.dart';
import 'screens/library_screen.dart';
import 'theme.dart';

void main() {
  runApp(const AudityPlayerApp());
}

class AudityPlayerApp extends StatelessWidget {
  const AudityPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audity Player',
      debugShowCheckedModeBanner: false,
      theme: AudityTheme.dark,
      darkTheme: AudityTheme.dark,
      themeMode: ThemeMode.dark,
      home: const LibraryScreen(),
    );
  }
}
