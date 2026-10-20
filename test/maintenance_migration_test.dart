import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/local/app_database.dart';

void main() {
  test(
    'v2 upgrade fills empty defaults but preserves saved intervals',
    () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute('''
            CREATE TABLE maintenance_templates (
              bike_type TEXT NOT NULL,
              service_name TEXT NOT NULL,
              interval_meters INTEGER,
              is_enabled INTEGER NOT NULL DEFAULT 1,
              updated_at TEXT NOT NULL,
              UNIQUE (bike_type, service_name)
            )
          ''');
            sqlite.execute('''
            INSERT INTO maintenance_templates
              (bike_type, service_name, interval_meters, is_enabled, updated_at)
            VALUES ('road', 'Transmisión', NULL, 1, '2026-01-01T00:00:00.000Z')
          ''');
            sqlite.execute('''
            INSERT INTO maintenance_templates
              (bike_type, service_name, interval_meters, is_enabled, updated_at)
            VALUES ('road', 'Frenos', 123456, 1, '2026-01-01T00:00:00.000Z')
          ''');
            sqlite.execute('PRAGMA user_version = 2');
          },
        ),
      );

      try {
        final templates = await database
            .watchMaintenanceTemplates(BikeType.road)
            .first;
        final intervals = {
          for (final template in templates)
            template.serviceName: template.intervalMeters,
        };

        expect(intervals['Transmisión'], 500000);
        expect(intervals['Frenos'], 123456);
      } finally {
        await database.close();
      }
    },
  );
}
