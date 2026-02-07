import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Language
  String getLanguage() => _prefs.getString(AppConstants.keyLanguage) ?? 'en';
  Future<void> setLanguage(String lang) => _prefs.setString(AppConstants.keyLanguage, lang);

  // Theme
  bool isDarkMode() => _prefs.getBool(AppConstants.keyTheme) ?? false;
  Future<void> setDarkMode(bool isDark) => _prefs.setBool(AppConstants.keyTheme, isDark);

  // Font Size
  int getFontSizeIndex() => _prefs.getInt(AppConstants.keyFontSize) ?? 1; // Default to Medium
  Future<void> setFontSizeIndex(int index) => _prefs.setInt(AppConstants.keyFontSize, index);

  // First Launch / Tutorial
  bool isFirstLaunch() => _prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
  Future<void> setFirstLaunch(bool isFirst) => _prefs.setBool(AppConstants.keyFirstLaunch, isFirst);

  bool isTutorialCompleted() => _prefs.getBool(AppConstants.keyTutorialCompleted) ?? false;
  Future<void> setTutorialCompleted(bool completed) => _prefs.setBool(AppConstants.keyTutorialCompleted, completed);
}
