import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String _onboardingKey = 'onboardingShown';

  // Verifica se o onboarding já foi mostrado
  static Future<bool> isOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Marca o onboarding como mostrado
  static Future<void> setOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
