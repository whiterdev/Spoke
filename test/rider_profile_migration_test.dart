import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/data/local/app_database.dart';

void main() {
  test('v3 upgrade adds a persistent rider profile', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) => sqlite.execute('PRAGMA user_version = 3'),
      ),
    );

    try {
      expect(await database.watchRiderProfile().first, isNull);

      await database.saveRiderName('  Walter  ');

      expect((await database.watchRiderProfile().first)?.displayName, 'Walter');

      await database.saveRiderName('Walt');
      expect((await database.watchRiderProfile().first)?.displayName, 'Walt');
    } finally {
      await database.close();
    }
  });
}
