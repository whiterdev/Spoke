import 'package:shared_preferences/shared_preferences.dart';

import 'google_maps_config.dart';

const _googleMapsEnabledKey = 'google_maps_enabled';

class GoogleMapsPreferences {
  GoogleMapsPreferences({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  Future<bool> isEnabled() async =>
      await _preferences.getBool(_googleMapsEnabledKey) ??
      googleMapsApiKeyConfigured;

  Future<void> setEnabled(bool enabled) =>
      _preferences.setBool(_googleMapsEnabledKey, enabled);
}

Future<bool> shouldUseGoogleMaps() async =>
    googleMapsApiKeyConfigured && await GoogleMapsPreferences().isEnabled();
