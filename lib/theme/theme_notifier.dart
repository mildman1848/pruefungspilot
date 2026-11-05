// Pfad: lib/theme/theme_notifier.dart – Notifier für Theme-Wechsel und Management.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Persistent Storage (Cross-OS kompatibel).
import 'package:flutter/foundation.dart' show kDebugMode; // Für Debugging.

// Enum für Theme-Modi (immutable, Best Practice).
enum AppThemeMode {
  system,
  calmNature,
  brightMinimal,
  darkElegant,
}

// Provider-Definition für den Theme-Notifier (Riverpod-Best Practice).
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppThemeState>((ref) => ThemeNotifier());

// Theme-Notifier-Klasse (StateNotifier für Riverpod).
class ThemeNotifier extends StateNotifier<AppThemeState> {
  ThemeNotifier() : super(AppThemeState.initial()) {
    _loadThemeMode(); // Asynchron laden beim Initialisieren.
  }

  // Theme-Modus setzen und speichern.
  void setThemeMode(AppThemeMode mode) {
    if (state.mode != mode) {
      state = state.copyWith(mode: mode);
      _saveThemeMode(); // Persistent speichern.
    }
  }

  // Für MaterialApp: ThemeMode abrufen (Cross-OS: System-Sync).
  ThemeMode get materialThemeMode {
    switch (state.mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      default:
        // User-spezifisch: Light als Default, da getThemeData Brightness handhabt.
        return ThemeMode.light;
    }
  }

  /// Holt das passende ThemeData – je nach Theme-Auswahl und Brightness (Best Practice: Dynamic für Material You).
  ThemeData getThemeData(Brightness platformBrightness) {
    switch (state.mode) {
      case AppThemeMode.calmNature:
        return platformBrightness == Brightness.dark
            ? AppThemes.calmNatureDark
            : AppThemes.calmNatureLight;
      case AppThemeMode.brightMinimal:
        return platformBrightness == Brightness.dark
            ? AppThemes.brightMinimalDark
            : AppThemes.brightMinimalLight;
      case AppThemeMode.darkElegant:
        return platformBrightness == Brightness.dark
            ? AppThemes.darkElegantDark
            : AppThemes.darkElegantLight;
      case AppThemeMode.system:
        // System-Theme: CalmNature als Default (Cross-OS kompatibel).
        return platformBrightness == Brightness.dark
            ? AppThemes.calmNatureDark
            : AppThemes.calmNatureLight;
    }
  }

  /// Initialisiert das gespeicherte Theme beim Start der App (asynchron).
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('theme_mode');
    if (mounted) { // Mounted-Check, um Zugriff nach Dispose zu vermeiden (behebt Bad State Error).
      if (value != null && value >= 0 && value < AppThemeMode.values.length) {
        state = state.copyWith(mode: AppThemeMode.values[value]);
      } else {
        state = state.copyWith(mode: AppThemeMode.system);
      }
      if (kDebugMode) debugPrint('Loaded theme: ${state.mode}'); // Debugging (Produktionstauglich).
    }
  }

  /// Speichert die Theme-Auswahl persistent (Cross-OS).
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', state.mode.index);
  }
}

// Immutable State für den Theme-Notifier (copyWith für Updates, Best Practice).
class AppThemeState {
  final AppThemeMode mode;

  AppThemeState({required this.mode});

  factory AppThemeState.initial() => AppThemeState(mode: AppThemeMode.system);

  AppThemeState copyWith({AppThemeMode? mode}) => AppThemeState(mode: mode ?? this.mode);
}

// ---------- Themes ---------- (Statische Theme-Definitionen, unverändert aber kommentiert).
class AppThemes {
  // Calm Nature – Light (Beispiel für helles Design).
  static final ThemeData calmNatureLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF388E3C),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF388E3C),
      secondary: Color(0xFFA5D6A7),
      surface: Color(0xFFFFF8E1),
    ),
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF388E3C),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF388E3C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF388E3C),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Calm Nature – Dark (Beispiel für dunkles Design).
  static final ThemeData calmNatureDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF29602E),
    scaffoldBackgroundColor: const Color(0xFF1B1B1B),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF66BB6A),
      secondary: Color(0xFFA5D6A7),
      surface: Color(0xFF23272A),
    ),
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF29602E),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF388E3C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF66BB6A),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );

  // Bright Minimal – Light
  static final ThemeData brightMinimalLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00B8D4),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B8D4),
      secondary: Color(0xFFFFB300),
      surface: Colors.white,
      tertiary: Color(0xFFD1C4E9),
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00B8D4),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B8D4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00B8D4),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Bright Minimal – Dark
  static final ThemeData brightMinimalDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0097A7),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00B8D4),
      secondary: Color(0xFFFFB300),
      surface: Color(0xFF23272A),
      tertiary: Color(0xFFD1C4E9),
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0097A7),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B8D4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00B8D4),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );

  // Dark Elegant – Light
  static final ThemeData darkElegantLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF23272A),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF23272A),
      secondary: Color(0xFF1ABC9C),
      surface: Color(0xFFF5F6FA),
      tertiary: Color(0xFF00E676),
      error: Color(0xFFFFD600),
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23272A),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1ABC9C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF1ABC9C),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Dark Elegant – Dark
  static final ThemeData darkElegantDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF23272A),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1ABC9C),
      secondary: Color(0xFF00E676),
      surface: Color(0xFF181A20),
      tertiary: Color(0xFFFFD600),
      error: Color(0xFFFFD600),
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23272A),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1ABC9C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00E676),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );
}

// Hilfsklasse für Themes (Best Practice: Erweiterbar für Material You/Dynamic Colors).
class AppTheme {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  AppTheme({required this.lightTheme, required this.darkTheme});
}