// Path: lib/screens/settings_screen.dart
// Description: Settings screen with theme selection, course switching, and progress reset.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_notifier.dart';
import '../providers/course_providers.dart';
import '../storage/progress_storage.dart';
import '../data/course_registry.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final currentMode = ref.watch(themeNotifierProvider).mode;
    final selectedCourse = ref.watch(selectedCourseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Active Course ──────────────────────────────────────────
          const Text(
            'Aktiver Lernbereich',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          if (selectedCourse != null)
            Card(
              child: ListTile(
                leading: Icon(selectedCourse.icon,
                    color: selectedCourse.primaryColor),
                title: Text(selectedCourse.title),
                subtitle: Text(selectedCourse.subtitle),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Wechseln'),
                  onPressed: () {
                    ref.read(selectedCourseIdProvider.notifier).state = null;
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ─── Progress Reset ─────────────────────────────────────────
          const Text(
            'Fortschritt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Fortschritt zurücksetzen'),
              subtitle: Text(
                selectedCourse != null
                    ? 'Setzt alle Lernergebnisse für "${selectedCourse.title}" zurück.'
                    : 'Kein Kurs ausgewählt.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Fortschritt zurücksetzen?'),
                    content: Text(
                      'Möchtest du wirklich alle Lernergebnisse für '
                      '"${selectedCourse?.title ?? 'diesen Kurs'}" unwiderruflich löschen?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.red),
                        child: const Text('Zurücksetzen'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ProgressStorage.resetAllProgress(ref);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fortschritt wurde zurückgesetzt.'),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // ─── Theme Selection ────────────────────────────────────────
          const Text(
            'Design-Auswahl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16),
          ...AppThemeMode.values.map((mode) {
            final isSelected = currentMode == mode;
            final Color base = Theme.of(context).colorScheme.secondary;
            final Color? highlight =
                isSelected ? base.withValues(alpha: 0.15) : null;

            return Semantics(
              label: _themeName(mode),
              child: Card(
                color: highlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(_iconForTheme(mode)),
                  title: Text(_themeName(mode)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: base)
                      : null,
                  onTap: () => themeNotifier.setThemeMode(mode),
                ),
              ),
            );
          }),

          // ─── About ──────────────────────────────────────────────────
          const SizedBox(height: 24),
          const Text(
            'Über die App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('LernApp – Multi-Course'),
              subtitle: Text(
                  '${allCourses.length} Kurse verfügbar • '
                  'Lokale Datenspeicherung • '
                  'Keine Cloud-Abhängigkeit'),
            ),
          ),
        ],
      ),
    );
  }
}

String _themeName(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return 'Automatisch (System)';
    case AppThemeMode.calmNature:
      return 'Calm Nature';
    case AppThemeMode.brightMinimal:
      return 'Bright Minimal';
    case AppThemeMode.darkElegant:
      return 'Dark Elegant';
  }
}

IconData _iconForTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return Icons.brightness_auto;
    case AppThemeMode.calmNature:
      return Icons.nature_people;
    case AppThemeMode.brightMinimal:
      return Icons.wb_sunny;
    case AppThemeMode.darkElegant:
      return Icons.nightlight_round;
  }
}
