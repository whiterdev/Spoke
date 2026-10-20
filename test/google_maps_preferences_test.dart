import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:spoke_app/app/google_maps_config.dart';
import 'package:spoke_app/app/google_maps_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('Google Maps defaults according to local key availability', () async {
    expect(
      await GoogleMapsPreferences().isEnabled(),
      googleMapsApiKeyConfigured,
    );
  });

  test('Google Maps preference persists between instances', () async {
    await GoogleMapsPreferences().setEnabled(true);

    expect(await GoogleMapsPreferences().isEnabled(), isTrue);
  });

  test('Google Maps can be turned off again', () async {
    final preferences = GoogleMapsPreferences();
    await preferences.setEnabled(true);
    await preferences.setEnabled(false);

    expect(await preferences.isEnabled(), isFalse);
  });

  test(
    'Google Maps remains unavailable until a local key is configured',
    () async {
      await GoogleMapsPreferences().setEnabled(true);

      expect(googleMapsApiKeyConfigured, isFalse);
      expect(await shouldUseGoogleMaps(), isFalse);
    },
  );
}
