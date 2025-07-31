import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString(
        'selectedLanguage', _getLanguageName(locale.languageCode));
    notifyListeners();
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      case 'en':
      default:
        return 'English';
    }
  }

  String getLanguageCode(String languageName) {
    switch (languageName) {
      case 'Sinhala':
        return 'si';
      case 'Tamil':
        return 'ta';
      case 'English':
      default:
        return 'en';
    }
  }
}
