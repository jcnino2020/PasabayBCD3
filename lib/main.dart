import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/db_initializer.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local SQLite database before anything else
  await DbInitializer.initialize();

  // Lock the app to portrait mode only (mobile app UX best practice)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent so the splash looks clean
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PasabayBCDApp());
}

class PasabayBCDApp extends StatelessWidget {
  const PasabayBCDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PasabayBCD',
      debugShowCheckedModeBanner: false,

      // Global theme - all screens share these styles
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display', // Falls back to system font if unavailable

        // App bar theme - clean and minimal
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF111827)),
        ),

        // Scaffold uses white background by default
        scaffoldBackgroundColor: Colors.white,

        // ElevatedButton global style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56DB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Text field global style
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1A56DB), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),

      // The app starts at the Splash Screen
      home: const SplashScreen(),
    );
  }
}
