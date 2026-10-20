# Spoke App — brief inicial

## Objetivo

Aplicación móvil Android para ciclismo: registrar salidas con GPS, revisar rutas recorridas y sus repeticiones personales, consultar mapas y llevar el historial de bicicletas y mantenimientos.

**Nombre de trabajo:** Spoke (provisional).

## Decisiones confirmadas

- **Plataforma:** Android, desarrollada con Flutter y Dart.
- **Alcance de la primera versión:** uso personal y local. No habrá cuentas, sincronización en la nube ni clasificaciones entre ciclistas en esta etapa.
- **Repeticiones:** comparar salidas completas de una ruta. La app propone coincidencias usando el trazado GPS completo, cercanía del inicio/final y distancia; la persona confirma antes de agruparlas.
- **Historial:** una sola lista reúne las salidas completadas; cada salida conserva su trazado GPS como ruta. Desde su detalle se puede abrir el mapa para seguir la línea con la ubicación actual o reproducir el recorrido con un marcador animado. No se copian ni se mueven salidas a otras rutas.
- **Seguimiento de rutas:** usar el mapa y GPS de la app sobre el trazado guardado, con avance estimado y aviso de desvío. No integrar por ahora Google Navigation SDK ni navegación giro a giro.
- **Datos:** las salidas, puntos GPS, bicicletas y mantenimientos se guardarán en SQLite en el teléfono.
- **Mapas:** Google Maps es el proveedor principal para grabar en vivo y consultar rutas guardadas. OpenStreetMap queda como respaldo si falta la clave, Google Maps no inicializa o se desactiva desde Perfil. La clave Android se configura localmente en `google_maps.local.json`.
- **Diseño visual:** tomar la segunda imagen como referencia principal: interfaz oscura en tonos azul petróleo/verde bosque, acento lima, métricas muy legibles, mapa y recorrido como protagonistas e imágenes de ciclismo al aire libre.
- **Tipografía:** Manrope variable, incluida como archivo local para mantener la misma apariencia sin depender de la red.
- **Bicicletas:** perfil por bicicleta con marca/modelo, foto, odómetro calculado desde las salidas asignadas y registro de mantenimientos.
- **Mantenimiento:** una plantilla inicial editable por tipo de bicicleta; cada servicio tiene un intervalo orientativo en kilómetros y el próximo se calcula con el último mantenimiento y los kilómetros acumulados.
- **Primer inicio y permisos:** pedir el nombre del ciclista y los permisos de ubicación necesarios al configurar el perfil. También solicitar notificaciones y ubicación en segundo plano; si Android exige habilitar esta última desde Ajustes, explicar el motivo y ofrecer abrirlos.

## Estado de implementación

- La navegación y la pantalla inicial usan el tema visual acordado y Manrope local.
- Drift ya define el almacenamiento local de salidas, puntos GPS, rutas, sugerencias de coincidencia, bicicletas y mantenimientos. El garaje permite crear y editar bicicletas con foto y odómetro, ajustar la plantilla de servicios por tipo y registrar fecha, kilometraje y notas de cada mantenimiento.
- El primer inicio configura el nombre y solicita ubicación, notificaciones y acceso en segundo plano. Si falta el permiso GPS al intentar grabar, el aviso explica el motivo y ofrece abrir los ajustes de Spoke; si la ubicación del teléfono está apagada, ofrece abrir los ajustes de ubicación. Al volver de Ajustes, el mapa vuelve a consultar permisos y servicios. El mapa muestra primero la última ubicación conocida mientras escucha en paralelo una posición GPS más reciente.
- El historial de mantenimiento y el próximo vencimiento se muestran por bicicleta. El odómetro suma las salidas completadas desde el kilometraje inicial y se actualiza cuando cambian las salidas locales.
- Las plantillas se inicializan con intervalos aproximados según tipo de bici y se pueden editar; se comparten entre las bicicletas del mismo tipo. La actualización desde la base local v2 completa solo intervalos todavía vacíos y conserva los valores configurados. Son recordatorios por kilómetros, no especificaciones universales: el uso, clima y terreno influyen, y algunos componentes —como las suspensiones— usan intervalos por horas y manuales específicos.
- La pantalla inicial consulta el resumen de los últimos siete días y las últimas salidas desde SQLite. El grabador GPS permite iniciar, pausar, reanudar, descartar y guardar salidas en SQLite; restaura una grabación interrumpida como pausada. Cada salida completada genera su ruta automáticamente y aparece en una única lista de Historial. Desde el detalle se puede abrir el mapa para seguir el trazado con la ubicación actual, ver el avance estimado y el desvío o reproducir el recorrido con una animación. El seguimiento es visual sobre la línea GPS guardada, sin navegación giro a giro. Google Maps es el mapa principal; OpenStreetMap queda como respaldo si la clave falta, el SDK no inicia en 20 segundos o la persona lo desactiva desde Perfil. Las salidas previas se comparan por trazado GPS, inicio/final y distancia para sugerir repeticiones que la persona confirma o descarta. Ya no hay una biblioteca separada de rutas ni acciones para copiar o mover salidas entre rutas.
- El APK de desarrollo compiló con Flutter 3.47.7, AGP 8.11.1, Gradle 8.14.3 y Kotlin 2.4.0. Flutter muestra una advertencia de que pronto exigirá versiones Android más nuevas; se revisará al migrar los plugins de Flutter restantes a Kotlin integrado.

## Stack propuesto

| Área | Propuesta | Uso |
| --- | --- | --- |
| Aplicación | Flutter / Dart | Android y UI compartida |
| Build Android | AGP 8.11.1 / Gradle 8.14.3 / Kotlin 2.4.0 | Versiones actuales verificadas para el APK de desarrollo |
| Estado | Riverpod | Estado de grabación, mapa y pantallas |
| Navegación | go_router | Navegación entre inicio, historial, grabación, bicicletas y perfil |
| Persistencia local | Drift sobre SQLite | Consultas tipadas, migraciones y almacenamiento de salidas, puntos GPS y bicicletas |
| Ubicación | Geolocator con servicio de ubicación en primer plano de Android | Mantener el registro mientras la pantalla está apagada o la app queda en segundo plano |
| Permisos Android | permission_handler | Solicitar notificaciones y ubicación en segundo plano cuando el sistema lo requiere |
| Mapas | Google Maps for Flutter; OpenStreetMap como respaldo | Ubicación actual, seguimiento de trazados GPS y reproducción de salidas; estilos estándar, relieve y satélite con cámara inclinada |
| Fotos | Archivo local asociado a la bicicleta | Evitar subir imágenes o datos personales en una versión sin nube |

Los paquetes de estado, navegación y ubicación son la propuesta inicial de implementación. Se pueden cambiar si aparece una limitación concreta al crear el prototipo.

## Alcance funcional inicial

1. Registrar una salida y guardar los puntos GPS localmente, incluso sin conexión.
2. Ver la distancia, duración, velocidad y desnivel de una salida.
3. Consultar las salidas en una única lista, seguir sus trazados y reproducirlos; detectar repeticiones personales.
4. Cambiar entre mapa estándar y satélite, inclinar la cámara y ver la línea de la salida.
5. Crear perfiles de bicicleta y asignar cada salida a una bici.
6. Registrar mantenimientos por bicicleta y calcular el próximo servicio según los kilómetros recorridos.

## Decisiones pendientes

- Revisar los umbrales iniciales de coincidencia tras probar recorridos reales: inicio/final a menos de 350 m, desviación del trazado de hasta 220 m, diferencia de distancia de hasta el mayor entre 400 m y 10 %, y similitud mínima de 50 %.
- Cerrar el nombre y el logotipo de la app (Spoke sigue siendo provisional).
- Elegir un proveedor de teselas OSM con SLA antes de distribuir la app; el servidor público de OSM es de mejor esfuerzo, tiene límites de uso y no admite precargas masivas.
- Definir si se ofrecerá descarga legal de mapas para usar el mapa sin conexión.
