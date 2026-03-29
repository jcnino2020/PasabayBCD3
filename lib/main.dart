import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/db_initializer.dart';
import 'screens/splash_screen.dart';

// Global notifier so SettingsScreen can toggle dark mode app-wide
final ValueNotifier<ThemeMode> appThemeMode =
    ValueNotifier(ThemeMode.light);

// Global accent color notifier
final ValueNotifier<Color> appAccentColor =
    ValueNotifier(const Color(0xFF1A56DB));

const List<Color> kAccentColors = [
  Color(0xFF1A56DB), // Blue
  Color(0xFF10B981), // Green
  Color(0xFFF59E0B), // Orange
  Color(0xFF8B5CF6), // Purple
  Color(0xFFEF4444), // Red
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await DbInitializer.initialize();
  }

  // Load persisted theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('setting_dark_mode') ?? false;
  appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final accentIndex = prefs.getInt('setting_accent_color') ?? 0;
  appAccentColor.value = kAccentColors[accentIndex.clamp(0, kAccentColors.length - 1)];

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: appAccentColor,
          builder: (context, accent, _) {
            return MaterialApp(
              title: 'PasabayBCD',
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              theme: _buildTheme(accent, Brightness.light),
              darkTheme: _buildTheme(accent, Brightness.dark),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme(Color seed, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        surfaceTintColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF111827)),
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF111111) : Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
    );
  }
}
