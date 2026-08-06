// test/theme_notifier_test.dart
// Tests the ThemeNotifier class.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lernapp/theme/theme_notifier.dart';

void main() {
  group('ThemeNotifier Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Returns correct theme based on brightness', () {
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);

      final lightTheme = themeNotifier.getThemeData(Brightness.light);
      expect(lightTheme.brightness, Brightness.light);

      final darkTheme = themeNotifier.getThemeData(Brightness.dark);
      expect(darkTheme.brightness, Brightness.dark);

      container.dispose();
    });

    test('materialThemeMode defaults to system', () {
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);

      expect(themeNotifier.materialThemeMode, ThemeMode.system);

      container.dispose();
    });

    testWidgets('Applies theme correctly in MaterialApp',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);
      final themeData = themeNotifier.getThemeData(Brightness.light);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: MaterialApp(
            theme: themeData,
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.light);

      container.dispose();
    });
  });
}
