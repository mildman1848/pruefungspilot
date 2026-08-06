# LernApp – Multi-Course Lernplattform

Englisch: [README.md](README.md)

Flutter-Lernapp für mehrere Prüfungen und Zertifizierungen. Lerne für den **Sachkundenachweis** (Hundeführerschein NRW), die **Begleithundprüfung** (BH/VT) und den **FiButroniker** (digitale Kanzlei).

## Highlights

- **Multi-Course-Plattform**: Nahtlos zwischen Lernbereichen wechseln.
- **3 Kurse enthalten**:
  - Sachkundenachweis (197 Fragen, 20 Kategorien)
  - Begleithundprüfung (115 Fragen, 12 Kategorien)
  - FiButroniker (120 Fragen, 12 Kategorien)
- Adaptives Lernen mit Spaced Repetition (3x korrekt = gelernt).
- Fortschrittsverfolgung pro Kurs (lokal via SharedPreferences).
- Mehrere Themes (Calm Nature, Bright Minimal, Dark Elegant).
- Responsive Layouts für Smartphone, Tablet und Desktop.
- 100% lokale Datenspeicherung — keine Cloud, kein Tracking.

## Tech Stack

- Flutter & Dart
- Riverpod (State Management)
- Freezed (Immutable Models)
- SharedPreferences (lokaler Fortschritt)
- Lottie (Animationen)
- Vibration (haptisches Feedback)

## Neuen Kurs hinzufügen

1. `assets/courses/{kurs_id}/questions.json` erstellen.
2. `Course(...)`-Eintrag in `lib/data/course_registry.dart` hinzufügen.
3. Asset-Pfad in `pubspec.yaml` eintragen.
4. Fertig — die App erkennt den Kurs automatisch.

## Lokale Entwicklung

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Quellen

- **Sachkundenachweis**: Offizieller Fragenkatalog Tierarztekammer Nordrhein.
- **Begleithundprüfung**: VDH-Prüfungsordnung (BH/VT).
- **FiButroniker**: IFU Institut für Bildung / ISM.
