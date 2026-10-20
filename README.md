# Spoke

Spoke es una aplicación Android para registrar salidas de ciclismo, consultar un historial de recorridos y administrar bicicletas y mantenimientos. Está hecha en Flutter y funciona de forma local: no requiere cuenta ni sincronización con un servidor.

## Qué incluye

- Grabación GPS de salidas y resumen de métricas.
- Historial único con el trazado de cada salida, seguimiento visual y reproducción animada.
- Sugerencias de coincidencia entre recorridos, que la persona confirma.
- Panel de inicio con métricas recientes y resumen de los últimos siete días.
- Perfiles de bicicletas con foto, odómetro y recordatorios de mantenimiento por kilómetros.
- Google Maps como proveedor principal y OpenStreetMap como alternativa.

## Stack

Flutter y Dart, Riverpod, go_router, Drift sobre SQLite, Geolocator, Google Maps for Flutter, flutter_map para OpenStreetMap, Shared Preferences, image_picker y la tipografía Manrope incluida en assets/fonts.

## Preparar el entorno

Se necesita Flutter estable compatible con la restricción indicada en pubspec.yaml, Android SDK y un emulador o dispositivo Android. El proyecto se validó con Flutter 3.47.7 y Dart 3.13.5. La compilación Android usa Java 17 como destino.

1. Instalá Flutter y Android Studio/Android SDK.
2. Desde PowerShell, en la raíz del proyecto, descargá las dependencias:

   ~~~powershell
   flutter pub get
   ~~~

3. Configurá Google Maps localmente siguiendo la guía de desarrollo y seguridad en docs/DEVELOPMENT.md.
4. Ejecutá la app:

   ~~~powershell
   .\tool\spoke_flutter.ps1
   ~~~

El script acepta el parámetro -DeviceId emulator-5554 para elegir el emulador. También podés compilar un APK de depuración con:

~~~powershell
.\tool\spoke_flutter.ps1 -Action build
~~~

## Documentación

- Guía de desarrollo, mapas, pruebas y protección de claves: docs/DEVELOPMENT.md
- Brief de producto y decisiones funcionales: PROJECT_BRIEF.md

## Antes de distribuir

La clave de Google Maps para Android forma parte de la configuración del cliente y queda dentro del APK; restringila en Google Cloud por aplicación Android y certificado. No guardes claves, archivos de firma ni datos privados en Git. La configuración de firma de producción todavía debe definirse antes de publicar una versión release.

OpenStreetMap es el respaldo. El servidor público de teselas tiene política y capacidad limitadas; antes de una distribución amplia elegí un proveedor compatible con el uso esperado. Consultá la guía enlazada para los detalles.
