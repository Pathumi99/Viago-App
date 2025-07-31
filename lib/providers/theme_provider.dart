import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = const Color(0xFF2563EB);
  bool _adaptiveTheme = false;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get adaptiveTheme => _adaptiveTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        // Load from Firestore first
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final selectedTheme = data['selectedTheme'] ?? 'Light';
          final selectedAccentColor = data['selectedAccentColor'] ?? 'Blue';
          _adaptiveTheme = data['adaptiveTheme'] ?? false;

          _themeMode = _getThemeModeFromString(selectedTheme);
          _accentColor = _getColorFromName(selectedAccentColor);
        }
      } else {
        // Fallback to SharedPreferences
        final themeModeString = prefs.getString('themeMode') ?? 'light';
        final accentColorString = prefs.getString('accentColor') ?? 'Blue';
        _adaptiveTheme = prefs.getBool('adaptiveTheme') ?? false;

        _themeMode = _getThemeModeFromString(themeModeString);
        _accentColor = _getColorFromName(accentColorString);
      }
    } catch (e) {
      // Use defaults
      _themeMode = ThemeMode.light;
      _accentColor = const Color(0xFF2563EB);
      _adaptiveTheme = false;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _saveThemeSettings();
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await _saveThemeSettings();
    notifyListeners();
  }

  Future<void> setAdaptiveTheme(bool adaptive) async {
    _adaptiveTheme = adaptive;
    await _saveThemeSettings();
    notifyListeners();
  }

  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    final themeModeString = _getStringFromThemeMode(_themeMode);
    final accentColorString = _getNameFromColor(_accentColor);

    // Save to SharedPreferences
    await prefs.setString('themeMode', themeModeString);
    await prefs.setString('accentColor', accentColorString);
    await prefs.setBool('adaptiveTheme', _adaptiveTheme);

    // Save to Firestore if user is logged in
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'selectedTheme': themeModeString,
          'selectedAccentColor': accentColorString,
          'adaptiveTheme': _adaptiveTheme,
        });
      } catch (e) {
        // Handle error silently or log it
        print('Error saving theme to Firestore: $e');
      }
    }
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: _getMaterialColor(_accentColor),
        primaryColor: _accentColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _accentColor;
            }
            return null;
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(color: Color(0xFF374151)),
          titleLarge:
              TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: _getMaterialColor(_accentColor),
        primaryColor: _accentColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: AppBarTheme(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _accentColor;
            }
            return null;
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE2E8F0)),
          bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
          titleLarge:
              TextStyle(color: Color(0xFFF1F5F9), fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w500),
        ),
      );

  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
      default:
        return 'Light';
    }
  }

  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'auto':
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  String _getNameFromColor(Color color) {
    if (color == const Color(0xFF2563EB)) return 'Blue';
    if (color == const Color(0xFF7C3AED)) return 'Purple';
    if (color == const Color(0xFF059669)) return 'Green';
    if (color == const Color(0xFFEA580C)) return 'Orange';
    if (color == const Color(0xFFE11D48)) return 'Pink';
    if (color == const Color(0xFF0D9488)) return 'Teal';
    return 'Blue';
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'blue':
        return const Color(0xFF2563EB);
      case 'purple':
        return const Color(0xFF7C3AED);
      case 'green':
        return const Color(0xFF059669);
      case 'orange':
        return const Color(0xFFEA580C);
      case 'pink':
        return const Color(0xFFE11D48);
      case 'teal':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF2563EB);
    }
  }

  MaterialColor _getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }
}
