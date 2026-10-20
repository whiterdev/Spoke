enum MapProvider { openStreetMap, googleMaps }

MapProvider liveMapProvider({required bool googleMapsEnabled}) =>
    googleMapsEnabled ? MapProvider.googleMaps : MapProvider.openStreetMap;

MapProvider savedRoutesMapProvider({required bool googleMapsEnabled}) =>
    googleMapsEnabled ? MapProvider.googleMaps : MapProvider.openStreetMap;
