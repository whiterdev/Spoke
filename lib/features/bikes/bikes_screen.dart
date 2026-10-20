import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/local/app_database_provider.dart';
import 'bikes_providers.dart';

class BikesScreen extends ConsumerWidget {
  const BikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(bikesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TU GARAJE',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mis bicicletas',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openBikeForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: bikes.when(
                data: (items) => items.isEmpty
                    ? _EmptyGarage(onAdd: () => _openBikeForm(context))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bike = items[index];
                          return _BikeCard(
                            bike: bike,
                            onEdit: () => _openBikeForm(context, bike: bike),
                            onOpenTemplate: () => _openTemplate(context, bike),
                          );
                        },
                      ),
                error: (error, stackTrace) => const _BikeDataErrorCard(),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BikeCard extends ConsumerWidget {
  const _BikeCard({
    required this.bike,
    required this.onEdit,
    required this.onOpenTemplate,
  });

  final Bike bike;
  final VoidCallback onEdit;
  final VoidCallback onOpenTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odometer = ref.watch(bikeOdometerProvider(bike.id));
    final title = [
      bike.brand,
      bike.model,
    ].where((part) => part.isNotEmpty).join(' ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _BikePhoto(path: bike.photoPath, size: 78),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.nickname?.isNotEmpty == true
                          ? bike.nickname!
                          : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (bike.nickname?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      BikeType.label(bike.type),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    odometer.when(
                      data: (meters) => Text(
                        '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km recorridos',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      error: (error, stackTrace) => const Text(
                        'Odómetro no disponible',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      loading: () => const Text(
                        'Calculando odómetro…',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar bicicleta',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenTemplate,
              icon: const Icon(Icons.build_circle_outlined, size: 18),
              label: Text('Mantenimiento · ${BikeType.label(bike.type)}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BikePhoto extends StatelessWidget {
  const _BikePhoto({required this.path, required this.size});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(17),
    child: SizedBox(
      width: size,
      height: size,
      child: path == null
          ? const _BikePhotoPlaceholder()
          : Image.file(
              File(path!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _BikePhotoPlaceholder(),
            ),
    ),
  );
}

class _BikePhotoPlaceholder extends StatelessWidget {
  const _BikePhotoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.raisedSurface,
    alignment: Alignment.center,
    child: const Icon(
      Icons.pedal_bike_rounded,
      color: AppColors.accent,
      size: 34,
    ),
  );
}

class _EmptyGarage extends StatelessWidget {
  const _EmptyGarage({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.accent,
            size: 30,
          ),
          const SizedBox(height: 12),
          const Text(
            'Agregá tu primera bici',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Guardá el modelo y el odómetro para calcular sus próximos servicios.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onAdd,
            child: const Text('Agregar bicicleta'),
          ),
        ],
      ),
    ),
  );
}

class _BikeDataErrorCard extends StatelessWidget {
  const _BikeDataErrorCard();

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'No se pudo abrir el garaje.',
      style: TextStyle(color: AppColors.secondaryText),
    ),
  );
}

void _openBikeForm(BuildContext context, {Bike? bike}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    builder: (_) => _BikeFormSheet(bike: bike),
  );
}

void _openTemplate(BuildContext context, Bike bike) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    builder: (_) => _MaintenanceTemplateSheet(bike: bike),
  );
}

class _BikeFormSheet extends ConsumerStatefulWidget {
  const _BikeFormSheet({this.bike});

  final Bike? bike;

  @override
  ConsumerState<_BikeFormSheet> createState() => _BikeFormSheetState();
}

class _BikeFormSheetState extends ConsumerState<_BikeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _odometerController = TextEditingController(text: '0');
  final _picker = ImagePicker();
  String _type = BikeType.mountain;
  XFile? _photo;
  bool _saving = false;
  bool _loadingOdometer = false;
  bool _odometerLoadFailed = false;
  int? _loadedOdometerMeters;

  @override
  void initState() {
    super.initState();
    final bike = widget.bike;
    if (bike == null) return;

    _brandController.text = bike.brand;
    _modelController.text = bike.model;
    _nicknameController.text = bike.nickname ?? '';
    _type = bike.type;
    _loadingOdometer = true;
    _loadOdometer(bike.id);
  }

  Future<void> _loadOdometer(int bikeId) async {
    try {
      final meters = await ref
          .read(appDatabaseProvider)
          .bikeOdometerMeters(bikeId);
      if (!mounted) return;
      _odometerController.text = (meters / 1000)
          .toStringAsFixed(3)
          .replaceAll('.', ',');
      setState(() {
        _loadedOdometerMeters = meters;
        _loadingOdometer = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingOdometer = false;
        _odometerLoadFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _nicknameController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1800,
    );
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  Future<String?> _persistPhoto() async {
    final photo = _photo;
    if (photo == null) return null;

    final supportDirectory = await getApplicationSupportDirectory();
    final photoDirectory = Directory(
      p.join(supportDirectory.path, 'bike_photos'),
    );
    await photoDirectory.create(recursive: true);
    final extension = p.extension(photo.name).isEmpty
        ? '.jpg'
        : p.extension(photo.name);
    final destination = File(
      p.join(
        photoDirectory.path,
        'bike_${DateTime.now().microsecondsSinceEpoch}$extension',
      ),
    );
    await File(photo.path).copy(destination.path);
    return destination.path;
  }

  Future<void> _save() async {
    if (_loadingOdometer || _odometerLoadFailed) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final bike = widget.bike;
      final photoPath = await _persistPhoto() ?? bike?.photoPath;
      final odometerKm = double.tryParse(
        _odometerController.text.trim().replaceAll(',', '.'),
      )!;
      final odometerMeters = (odometerKm * 1000).round();
      final resetOdometer =
          bike == null || odometerMeters != _loadedOdometerMeters;
      final changes = BikesCompanion(
        type: Value(_type),
        brand: Value(_brandController.text.trim()),
        model: Value(_modelController.text.trim()),
        nickname: Value(
          _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
        ),
        photoPath: Value(photoPath),
        odometerBaselineMeters: resetOdometer
            ? Value(odometerMeters)
            : const Value.absent(),
        odometerBaselineAt: resetOdometer
            ? Value(DateTime.now().toUtc())
            : const Value.absent(),
      );
      final database = ref.read(appDatabaseProvider);
      if (bike == null) {
        await database.createBike(changes);
      } else {
        final updatedRows = await database.updateBike(bike.id, changes);
        if (updatedRows == 0) {
          throw StateError('La bicicleta ya no existe.');
        }
        ref.invalidate(bikeOdometerProvider(bike.id));
        ref.invalidate(bikeMaintenanceForecastsProvider(bike.id));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la bicicleta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 22, 22, bottomInset + 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.bike == null ? 'Nueva bicicleta' : 'Editar bicicleta',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: SizedBox(
                      width: 112,
                      height: 112,
                      child: _photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                File(_photo!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : (widget.bike?.photoPath == null
                                ? const _BikePhotoPlaceholder()
                                : _BikePhoto(
                                    path: widget.bike!.photoPath,
                                    size: 112,
                                  )),
                    ),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(
                      _photo == null && widget.bike?.photoPath == null
                          ? 'Agregar foto'
                          : 'Cambiar foto',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _textField(_brandController, 'Marca', requiredField: true),
                const SizedBox(height: 12),
                _textField(_modelController, 'Modelo', requiredField: true),
                const SizedBox(height: 12),
                _textField(_nicknameController, 'Nombre (opcional)'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de bicicleta',
                  ),
                  items: [
                    for (final type in BikeType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(BikeType.label(type)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 12),
                _textField(
                  _odometerController,
                  'Odómetro actual (km)',
                  enabled: !_loadingOdometer && !_odometerLoadFailed,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffixIcon: _loadingOdometer
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );
                    if (parsed == null || !parsed.isFinite || parsed < 0) {
                      return 'Ingresá un kilometraje válido.';
                    }
                    return null;
                  },
                ),
                if (_odometerLoadFailed) ...[
                  const SizedBox(height: 6),
                  Text(
                    'No se pudo calcular el odómetro. Cerrá y volvé a abrir la edición.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _saving || _loadingOdometer || _odometerLoadFailed
                        ? null
                        : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.bike == null
                                ? 'Guardar bicicleta'
                                : 'Guardar cambios',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    validator:
        validator ??
        (requiredField
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Este campo es obligatorio.'
                  : null
            : null),
  );
}

class _MaintenanceTemplateSheet extends ConsumerWidget {
  const _MaintenanceTemplateSheet({required this.bike});

  final Bike bike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikeType = bike.type;
    final templates = ref.watch(maintenanceTemplatesProvider(bikeType));
    final forecasts = ref.watch(bikeMaintenanceForecastsProvider(bike.id));
    final events = ref.watch(bikeMaintenanceEventsProvider(bike.id));
    final odometer = ref.watch(bikeOdometerProvider(bike.id));
    ref.listen(maintenanceTemplatesProvider(bikeType), (_, _) {
      ref.invalidate(bikeMaintenanceForecastsProvider(bike.id));
    });

    final recordServiceAction = templates.when(
      data: (items) => odometer.when(
        data: (meters) {
          final enabledServices = items
              .where((item) => item.isEnabled)
              .toList();
          return enabledServices.isEmpty
              ? null
              : () => _recordMaintenance(
                  context,
                  ref,
                  bike,
                  enabledServices,
                  meters,
                );
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      error: (error, stackTrace) => null,
      loading: () => null,
    );

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bike.nickname?.isNotEmpty == true
                    ? 'Mantenimiento · ${bike.nickname}'
                    : 'Mantenimiento · ${bike.brand} ${bike.model}',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              odometer.when(
                data: (meters) => Text(
                  'Odómetro actual: ${(meters / 1000).toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                error: (error, stackTrace) => const Text(
                  'Odómetro no disponible',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                loading: () => const Text(
                  'Calculando odómetro…',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    const _MaintenanceSectionTitle('PRÓXIMOS SERVICIOS'),
                    const SizedBox(height: 8),
                    forecasts.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const _MaintenanceInfoTile(
                            text: 'Registrá un servicio y definí su intervalo para calcular el próximo vencimiento.',
                          );
                        }
                        final sorted = [...items]
                          ..sort(
                            (a, b) =>
                                a.remainingMeters.compareTo(b.remainingMeters),
                          );
                        return Column(
                          children: [
                            for (final forecast in sorted) ...[
                              _MaintenanceForecastTile(forecast: forecast),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      },
                      error: (error, stackTrace) => const _MaintenanceInfoTile(
                        text: 'No se pudieron calcular los vencimientos.',
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _MaintenanceSectionTitle(
                      'PLANTILLA · ${BikeType.label(bikeType)}',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Intervalos orientativos por tipo, editables y compartidos entre bicis de ese tipo. Ajustalos al uso y al manual del componente; algunas suspensiones se revisan por horas.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    templates.when(
                      data: (items) => items.isEmpty
                          ? const _MaintenanceInfoTile(
                              text: 'Todavía no hay servicios en la plantilla.',
                            )
                          : Column(
                              children: [
                                for (final template in items) ...[
                                  _TemplateTile(
                                    bikeType: bikeType,
                                    template: template,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                      error: (error, stackTrace) => const _MaintenanceInfoTile(
                        text: 'No se pudo cargar la plantilla.',
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _MaintenanceSectionTitle('HISTORIAL RECIENTE'),
                    const SizedBox(height: 8),
                    events.when(
                      data: (items) => items.isEmpty
                          ? const _MaintenanceInfoTile(
                              text: 'Todavía no hay servicios registrados para esta bici.',
                            )
                          : Column(
                              children: [
                                for (final event in items) ...[
                                  _MaintenanceEventTile(event: event),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                      error: (error, stackTrace) => const _MaintenanceInfoTile(
                        text: 'No se pudo cargar el historial.',
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: recordServiceAction,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Registrar mantenimiento'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _editTemplate(context, ref, bikeType),
                icon: const Icon(Icons.tune_rounded, size: 17),
                label: const Text('Editar plantilla de servicio'),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceSectionTitle extends StatelessWidget {
  const _MaintenanceSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.accent,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
    ),
  );
}

class _MaintenanceInfoTile extends StatelessWidget {
  const _MaintenanceInfoTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.divider),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.secondaryText,
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );
}

class _MaintenanceForecastTile extends StatelessWidget {
  const _MaintenanceForecastTile({required this.forecast});

  final MaintenanceForecast forecast;

  @override
  Widget build(BuildContext context) {
    final remainingKm = (forecast.remainingMeters.abs() / 1000).toStringAsFixed(
      0,
    );
    final status = forecast.remainingMeters < 0
        ? 'Vencido por $remainingKm km'
        : forecast.remainingMeters == 0
        ? 'Vence ahora'
        : 'Faltan $remainingKm km';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: forecast.isDue ? AppColors.accent : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            forecast.isDue ? Icons.warning_amber_rounded : Icons.build_outlined,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecast.event.serviceName,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Próximo: ${(forecast.dueAtOdometerMeters / 1000).toStringAsFixed(0)} km · $status',
                  style: TextStyle(
                    color: forecast.isDue
                        ? AppColors.accent
                        : AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceEventTile extends StatelessWidget {
  const _MaintenanceEventTile({required this.event});

  final MaintenanceEvent event;

  @override
  Widget build(BuildContext context) {
    final date = event.servicedAt.toLocal();
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.serviceName,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$dateLabel · ${(event.odometerMeters / 1000).toStringAsFixed(1)} km',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
          if (event.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 5),
            Text(
              event.notes!,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _recordMaintenance(
  BuildContext context,
  WidgetRef ref,
  Bike bike,
  List<MaintenanceTemplate> templates,
  int currentOdometerMeters,
) async {
  final result = await showDialog<_MaintenanceEventFormResult>(
    context: context,
    builder: (_) => _MaintenanceEventEditor(
      templates: templates,
      currentOdometerMeters: currentOdometerMeters,
    ),
  );
  if (result == null || !context.mounted) return;

  try {
    await ref
        .read(appDatabaseProvider)
        .recordMaintenanceEvent(
          bikeId: bike.id,
          serviceName: result.serviceName,
          servicedAt: result.servicedAt,
          odometerMeters: (result.odometerKm * 1000).round(),
          notes: result.notes,
        );
    ref.invalidate(bikeMaintenanceForecastsProvider(bike.id));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo registrar el mantenimiento.')),
    );
  }
}

class _MaintenanceEventFormResult {
  const _MaintenanceEventFormResult({
    required this.serviceName,
    required this.servicedAt,
    required this.odometerKm,
    required this.notes,
  });

  final String serviceName;
  final DateTime servicedAt;
  final double odometerKm;
  final String? notes;
}

class _MaintenanceEventEditor extends StatefulWidget {
  const _MaintenanceEventEditor({
    required this.templates,
    required this.currentOdometerMeters,
  });

  final List<MaintenanceTemplate> templates;
  final int currentOdometerMeters;

  @override
  State<_MaintenanceEventEditor> createState() =>
      _MaintenanceEventEditorState();
}

class _MaintenanceEventEditorState extends State<_MaintenanceEventEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _odometerController = TextEditingController(
    text: (widget.currentOdometerMeters / 1000).toStringAsFixed(1),
  );
  final _notesController = TextEditingController();
  late String _serviceName = widget.templates.first.serviceName;
  DateTime _servicedAt = DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _servicedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (selected != null) setState(() => _servicedAt = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final odometerKm = double.parse(
      _odometerController.text.trim().replaceAll(',', '.'),
    );
    Navigator.of(context).pop(
      _MaintenanceEventFormResult(
        serviceName: _serviceName,
        servicedAt: _servicedAt,
        odometerKm: odometerKm,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_servicedAt.day.toString().padLeft(2, '0')}/${_servicedAt.month.toString().padLeft(2, '0')}/${_servicedAt.year}';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Registrar servicio',
        style: TextStyle(color: AppColors.primaryText),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _serviceName,
                decoration: const InputDecoration(labelText: 'Servicio'),
                items: [
                  for (final template in widget.templates)
                    DropdownMenuItem(
                      value: template.serviceName,
                      child: Text(template.serviceName),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _serviceName = value);
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  child: Row(
                    children: [
                      Expanded(child: Text(dateLabel)),
                      const Icon(Icons.calendar_today_rounded, size: 17),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _odometerController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Odómetro al hacer el servicio (km)',
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (parsed == null || !parsed.isFinite || parsed < 0) {
                    return 'Ingresá un kilometraje válido.';
                  }
                  if ((parsed * 1000).round() > widget.currentOdometerMeters) {
                    return 'Supera el odómetro actual de '
                        '${(widget.currentOdometerMeters / 1000).toStringAsFixed(1)} km.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

class _TemplateTile extends ConsumerWidget {
  const _TemplateTile({required this.bikeType, required this.template});

  final String bikeType;
  final MaintenanceTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalKm = template.intervalMeters == null
        ? 'Intervalo sin configurar'
        : 'Cada ${(template.intervalMeters! / 1000).toStringAsFixed(0)} km';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.serviceName,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  template.isEnabled ? intervalKm : 'Desactivado',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar intervalo',
            onPressed: () =>
                _editTemplate(context, ref, bikeType, template: template),
            icon: const Icon(Icons.tune_rounded, color: AppColors.accent),
          ),
          Switch.adaptive(
            value: template.isEnabled,
            activeTrackColor: AppColors.accent,
            onChanged: (enabled) => ref
                .read(appDatabaseProvider)
                .saveMaintenanceTemplate(
                  bikeType: bikeType,
                  serviceName: template.serviceName,
                  intervalMeters: template.intervalMeters,
                  isEnabled: enabled,
                ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editTemplate(
  BuildContext context,
  WidgetRef ref,
  String bikeType, {
  MaintenanceTemplate? template,
}) async {
  final result = await showDialog<_TemplateFormResult>(
    context: context,
    builder: (_) => _TemplateEditor(template: template),
  );
  if (result == null) return;

  await ref
      .read(appDatabaseProvider)
      .saveMaintenanceTemplate(
        bikeType: bikeType,
        serviceName: result.serviceName,
        intervalMeters: result.intervalMeters,
        isEnabled: template?.isEnabled ?? true,
      );
}

class _TemplateFormResult {
  const _TemplateFormResult({
    required this.serviceName,
    required this.intervalMeters,
  });

  final String serviceName;
  final int? intervalMeters;
}

class _TemplateEditor extends StatefulWidget {
  const _TemplateEditor({required this.template});

  final MaintenanceTemplate? template;

  @override
  State<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<_TemplateEditor> {
  late final _nameController = TextEditingController(
    text: widget.template?.serviceName ?? '',
  );
  late final _intervalController = TextEditingController(
    text: widget.template?.intervalMeters == null
        ? ''
        : (widget.template!.intervalMeters! / 1000).toStringAsFixed(0),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final intervalKm = double.tryParse(
      _intervalController.text.trim().replaceAll(',', '.'),
    );
    Navigator.of(context).pop(
      _TemplateFormResult(
        serviceName: _nameController.text.trim(),
        intervalMeters: intervalKm == null ? null : (intervalKm * 1000).round(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface,
    title: Text(
      widget.template == null ? 'Nuevo servicio' : 'Editar intervalo',
      style: const TextStyle(color: AppColors.primaryText),
    ),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            readOnly: widget.template != null,
            decoration: const InputDecoration(labelText: 'Servicio'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ingresá un nombre.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _intervalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Intervalo en kilómetros',
              hintText: 'Vacío = sin cálculo',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
              if (parsed == null || !parsed.isFinite || parsed <= 0) {
                return 'Usá una distancia mayor a cero.';
              }
              return null;
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Guardar')),
    ],
  );
}
