import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/app_theme.dart';
import '../../app/google_maps_config.dart';
import '../../app/google_maps_preferences.dart';
import '../../data/local/app_database_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _googleMapsPreferences = GoogleMapsPreferences();
  bool _mapPreferencesReady = false;
  bool _googleMapsEnabled = false;
  bool _savingMapPreference = false;

  @override
  void initState() {
    super.initState();
    _loadMapPreferences();
  }

  Future<void> _loadMapPreferences() async {
    try {
      final googleMapsEnabled = googleMapsApiKeyConfigured
          ? await _googleMapsPreferences.isEnabled()
          : false;
      if (!mounted) return;
      setState(() {
        _googleMapsEnabled = googleMapsEnabled;
        _mapPreferencesReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _mapPreferencesReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(riderProfileProvider).asData?.value;
    final name = profile?.displayName ?? 'Ciclista';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TU PERFIL',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hola, $name',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.raisedSurface,
                  foregroundColor: AppColors.accent,
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Editar nombre',
                  onPressed: () => _editName(context, ref, name),
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                secondary: const Icon(
                  Icons.map_outlined,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Google Maps principal',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  !googleMapsApiKeyConfigured
                      ? 'No hay una clave de Google Maps configurada.'
                      : _googleMapsEnabled
                      ? 'En vivo y en tus rutas guardadas.'
                      : 'OpenStreetMap se usa como respaldo.',
                ),
                value: googleMapsApiKeyConfigured && _googleMapsEnabled,
                onChanged:
                    !googleMapsApiKeyConfigured ||
                        !_mapPreferencesReady ||
                        _savingMapPreference
                    ? null
                    : _setGoogleMapsEnabled,
                activeTrackColor: AppColors.accent,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                leading: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Permisos de la app',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text('Ubicación y notificaciones'),
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.secondaryText,
                  size: 18,
                ),
                onTap: () => Geolocator.openAppSettings(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setGoogleMapsEnabled(bool enabled) async {
    if (_savingMapPreference || !googleMapsApiKeyConfigured) return;

    if (enabled) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Usar Google Maps'),
              content: const Text(
                'Google Maps será el mapa principal para grabar y consultar rutas. OpenStreetMap queda como respaldo. Puede consumir cuota del proyecto de Google Maps Platform.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Activar'),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed || !mounted) return;
    }

    setState(() => _savingMapPreference = true);
    try {
      await _googleMapsPreferences.setEnabled(enabled);
      if (mounted) {
        setState(() => _googleMapsEnabled = enabled);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar esta preferencia.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingMapPreference = false);
    }
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            counterText: '',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !context.mounted) return;

    try {
      await ref.read(appDatabaseProvider).saveRiderName(name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el nombre.')),
        );
      }
    }
  }
}
