import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spoke_app/app/spoke_app.dart';
import 'package:spoke_app/data/local/app_database.dart';
import 'package:spoke_app/data/local/app_database_provider.dart';

void main() {
  testWidgets('first launch asks for the rider name before continuing', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => database),
          riderProfileProvider.overrideWith(
            (ref) => Stream<RiderProfile?>.value(null),
          ),
        ],
        child: const SpokeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prepará tu perfil'), findsOneWidget);
    expect(find.text('¿Cómo te llamamos?'), findsOneWidget);

    final continueButton = find.widgetWithText(FilledButton, 'Continuar');
    expect(continueButton, findsOneWidget);
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Walter');
    await tester.pump();

    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
}
