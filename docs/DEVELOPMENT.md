# Desarrollo y seguridad

Esta guía describe cómo preparar Spoke desde un clon limpio, configurar los mapas sin guardar claves en Git y ejecutar las comprobaciones del proyecto.

## Requisitos

- Flutter estable compatible con la versión de Dart indicada en pubspec.yaml. La versión validada en este entorno fue Flutter 3.47.7 y Dart 3.13.5.
- Android SDK y un emulador o teléfono Android con depuración USB.
- Java instalado. El proyecto apunta a Java 17 para compilar; también se validó con JDK 21.
- Una clave de Google Maps Platform para usar Google Maps. Sin ella, o si se elige el respaldo, la app puede usar OpenStreetMap.

## Preparación

En PowerShell, desde la raíz:

~~~powershell
flutter pub get
Copy-Item google_maps.local.example.json google_maps.local.json
~~~

Editá google_maps.local.json y reemplazá el texto de ejemplo por tu clave. El archivo real está excluido de Git. No compartas su contenido en chats, capturas ni logs.

En Google Cloud:

1. Habilitá Maps SDK for Android en el proyecto que contiene la clave.
2. Configurá la facturación requerida por Google Maps Platform.
3. Restringí la clave a la aplicación Android com.spoke.spoke_app y al certificado de firma correspondiente. Configurá por separado las huellas de depuración y de producción.
4. Habilitá solo las API necesarias para la app.

La clave de Android se incorpora al manifiesto de la aplicación al compilar; cualquier usuario que extraiga el APK puede recuperarla. Es una clave cliente, no una contraseña de backend: protegela con las restricciones de Google Cloud y cuotas. No la escribas directamente en Dart, Kotlin, archivos Gradle versionados ni documentación.

## Ejecutar y compilar

Usá el script del proyecto para ejecutar la app:

~~~powershell
.\tool\spoke_flutter.ps1
~~~

Para seleccionar un dispositivo:

~~~powershell
.\tool\spoke_flutter.ps1 -DeviceId emulator-5554
~~~

Para compilar un APK de depuración:

~~~powershell
.\tool\spoke_flutter.ps1 -Action build
~~~

El script lee la clave local sin escribir su valor en la consola. También indica a Flutter si la clave está configurada; Gradle la lee para completar la configuración Android. Por eso conviene usar el script del proyecto y no pasar claves mediante argumentos visibles en la terminal.

## Proveedores de mapas

Google Maps es el proveedor principal tanto para grabar como para consultar salidas guardadas. La preferencia se conserva localmente. OpenStreetMap funciona como alternativa cuando falta la configuración, se selecciona el respaldo o Google Maps no inicia. En las pantallas de mapas, la información de atribución se abre desde el botón de información.

El respaldo usa las teselas del servidor público de OpenStreetMap. Ese servicio comunitario tiene una política de uso, capacidad limitada y no ofrece un SLA. Antes de distribuir Spoke o generar tráfico significativo, configurá un proveedor de teselas adecuado y respetá su política. No presupongas que el servicio público admite uso sin conexión o descargas masivas.

## Datos y estructura

La app no tiene backend, cuentas ni sincronización en esta versión. Drift administra SQLite en el almacenamiento privado de la app. Allí se guardan salidas, puntos GPS, bicicletas, plantillas y eventos de mantenimiento, además de sugerencias de coincidencia de rutas. Las fotos de bicicletas se seleccionan en el dispositivo.

Las partes principales del código están organizadas así:

- lib/app: tema, marca, navegación, configuración y selección de proveedores.
- lib/data/local: base SQLite/Drift, migraciones y consultas locales.
- lib/data/routes: comparación y segmentación de trazados.
- lib/features/home: panel de métricas recientes.
- lib/features/record: selección de bicicleta y grabación GPS.
- lib/features/routes: historial, seguimiento y reproducción.
- lib/features/bikes: bicicletas y mantenimiento.
- lib/features/profile y lib/features/onboarding: preferencias y primer inicio.
- android: configuración Android, permisos y clave de Maps.
- test: pruebas unitarias y de interfaz.

La app guarda cada salida completada como su recorrido. Las coincidencias entre salidas se sugieren para que la persona las confirme. El seguimiento de una salida usa el trazado registrado y la ubicación GPS; no implementa navegación giro a giro.

## Comprobaciones

~~~powershell
flutter analyze
flutter test
~~~

Si modificás las tablas de Drift, regenerá el código de base de datos:

~~~powershell
dart run build_runner build --delete-conflicting-outputs
~~~

La configuración release de Android todavía usa firma de depuración. Antes de publicar, configurá una clave de firma de producción y guardá sus archivos y contraseñas fuera del repositorio.

## Archivos locales y Git

El repositorio ignora las claves de Maps, propiedades locales de Android, archivos de firma, variables de entorno, cachés, resultados de compilación y capturas de pantalla. Para confirmar que la clave local está excluida:

~~~powershell
git check-ignore -v google_maps.local.json
git status --short
~~~

Antes de crear un commit, revisá los archivos que se van a subir y buscá accidentalmente claves o datos privados. No subas bases SQLite de prueba, fotos personales, salidas GPS reales, capturas que muestren ubicaciones, archivos de firma ni configuraciones locales. El archivo google_maps.local.example.json contiene solo un marcador de posición y sí puede versionarse.
