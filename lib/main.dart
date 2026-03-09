// ============================================================
// main.dart - PasabayBCD Entry Point
// SME Logistics Hub for Bacolod City small market vendors
//
// Project structure:
//   lib/
//     main.dart               <- You are here
//     screens/
//       splash_screen.dart    <- Screen 01
//       onboarding_screen.dart  <- Screen 02
//       login_screen.dart       <- Screen 03
//       trip_matching_screen.dart <- Screen 04 (Core)
//       trip_details_screen.dart  <- Screen 05
//       cargo_form_screen.dart    <- Screen 06 (Core)
//       driver_confirmation_screen.dart <- Screen 07
//       live_tracking_screen.dart  <- Screen 08 (Core)
//       savings_dashboard_screen.dart <- Screen 09
//       profile_screen.dart     <- Screen 10
//     widgets/
//       bottom_nav_bar.dart   <- Shared nav bar
//       truck_card.dart       <- Truck listing card
//     models/
//       truck.dart            <- Truck data + sample data
//       booking.dart          <- Booking data + transactions
//
// State management: StatefulWidget + setState() only
// Navigation: Navigator.push() / Navigator.pop()
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
