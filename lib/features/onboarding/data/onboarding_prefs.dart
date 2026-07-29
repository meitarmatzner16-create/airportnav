import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has completed (or skipped) onboarding.
///
/// The onboarding screen always wrote this flag - but the splash never read
/// it, which is why every cold launch went back to onboarding. Key kept as
/// `onboarding_complete` so existing installs stay logged in.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const _key = 'onboarding_complete';

  static Future<bool> seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
