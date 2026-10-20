import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_theme.dart';
import '../../app/spoke_brand_mark.dart';
import '../../data/local/app_database_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _isWorking = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isWorking) return;

    setState(() => _isWorking = true);
    var openSettings = false;

    try {
      var location = await Geolocator.checkPermission();
      if (location == LocationPermission.denied) {
        location = await Geolocator.requestPermission();
      }

      final hasForegroundLocation =
          location != LocationPermission.denied &&
          location != LocationPermission.deniedForever;

      if (hasForegroundLocation) {
        try {
          final notification = await Permission.notification.status;
          if (!notification.isGranted && !notification.isPermanentlyDenied) {
            await Permission.notification.request();
          }
        } catch (_) {
          // Notifications are useful during recording, but optional.
        }

        if (location != LocationPermission.always) {
          try {
            final background = await Permission.locationAlways.status;
            if (!background.isGranted) {
              final result = await Permission.locationAlways.request();
              if (!result.isGranted) {
                openSettings = await _askToOpenSettings(
                  title: 'Grabar con la pantalla apagada',
                  message: 'Activa «Permitir todo el tiempo» en los ajustes de ubicación de Spoke.',
                );
              }
            }
          } catch (_) {
            // The user can enable background location later from the profile.
          }
        }
      } else if (location == LocationPermission.deniedForever) {
        openSettings = await _askToOpenSettings(
          title: 'Habilitar ubicación',
          message: 'Spoke necesita ubicación para dibujar tus recorridos.',
        );
      }

      await ref.read(appDatabaseProvider).saveRiderName(name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo completar la configuración.'),
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }

    if (openSettings) await Geolocator.openAppSettings();
  }

  Future<bool> _askToOpenSettings({
    required String title,
    required String message,
  }) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Ahora no'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SpokeBrandMark(size: 44),
                      const SizedBox(width: 12),
                      Text(
                        'SPOKE',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Text(
                    'Prepará tu perfil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¿Cómo te llamamos?',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    enabled: !_isWorking,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    maxLength: 60,
                    onSubmitted: (_) => _continue(),
                    decoration: InputDecoration(
                      labelText: 'Tu nombre',
                      hintText: 'Nombre',
                      counterText: '',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 27),
                  const Text(
                    'Para registrar tus salidas',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _PermissionItem(
                    icon: Icons.location_on_outlined,
                    title: 'Ubicación',
                    description: 'Dibuja el recorrido y mide la distancia.',
                  ),
                  const SizedBox(height: 13),
                  const _PermissionItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notificaciones',
                    description: 'Muestra el estado mientras grabas.',
                  ),
                  const SizedBox(height: 13),
                  const _PermissionItem(
                    icon: Icons.screen_lock_portrait_outlined,
                    title: 'Ubicación en segundo plano',
                    description: 'Sigue grabando al bloquear el teléfono.',
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _nameController,
                      builder: (context, value, _) => FilledButton(
                        onPressed: value.text.trim().isNotEmpty && !_isWorking
                            ? _continue
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.raisedSurface,
                          disabledForegroundColor: AppColors.secondaryText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        child: _isWorking
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Continuar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.raisedSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent, size: 19),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
