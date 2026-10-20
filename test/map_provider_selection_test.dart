import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/app/map_provider_selection.dart';

void main() {
  test('live recording uses OpenStreetMap by default', () {
    expect(
      liveMapProvider(googleMapsEnabled: false),
      MapProvider.openStreetMap,
    );
  });

  test('Google Maps replaces the live recording map when enabled', () {
    expect(liveMapProvider(googleMapsEnabled: true), MapProvider.googleMaps);
  });

  test('saved routes use OpenStreetMap when Google Maps is disabled', () {
    expect(
      savedRoutesMapProvider(googleMapsEnabled: false),
      MapProvider.openStreetMap,
    );
  });

  test('Google Maps is selected for saved routes when enabled', () {
    expect(
      savedRoutesMapProvider(googleMapsEnabled: true),
      MapProvider.googleMaps,
    );
  });
}
