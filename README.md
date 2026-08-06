# LernApp – Multi-Course Learning Platform

Deutsch: [README.DE.md](README.DE.md)

Flutter learning app for multiple certification exams. Study for **Sachkundenachweis** (dog ownership certification NRW), **Begleithundprüfung** (BH/VT companion dog test), and **FiButroniker** (digital accounting certification).

## Highlights

- **Multi-course platform**: Switch between study areas seamlessly.
- **3 courses included**:
  - Sachkundenachweis (197 questions, 20 categories)
  - Begleithundprüfung (115 questions, 12 categories)
  - FiButroniker (120 questions, 12 categories)
- Adaptive learning with spaced repetition (3x correct = learned).
- Per-course progress tracking with SharedPreferences.
- Multiple themes (Calm Nature, Bright Minimal, Dark Elegant).
- Responsive layouts for phone, tablet, and desktop.
- Local-only data storage — no cloud, no tracking.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- Freezed for immutable models
- SharedPreferences for local progress data
- Lottie for animations
- Vibration for haptic feedback

## Architecture

```
lib/
├── models/
│   ├── course_model.dart          # Course class (id, title, categories, ...)
│   └── question_model.dart        # Question class (Freezed)
├── data/
│   ├── course_registry.dart       # All course definitions
│   └── questions.dart             # Legacy compatibility shim
├── providers/
│   └── course_providers.dart      # selectedCourseProvider, questionsProvider
├── screens/
│   ├── course_selection_screen.dart  # Entry: pick a course
│   ├── dashboard_screen.dart         # Per-course progress overview
│   ├── category_detail_screen.dart   # Questions within a category
│   ├── category_learning_screen.dart # Sequential learning mode
│   ├── quiz_screen.dart              # Randomized quiz mode
│   ├── single_question_screen.dart   # Single question practice
│   └── settings_screen.dart          # Theme, course switch, reset
├── storage/
│   ├── progress_storage.dart         # Course-namespaced progress (SharedPreferences)
│   └── progress_dashboard.dart       # Per-category progress calculation
└── theme/
    └── theme_notifier.dart           # Theme management (Riverpod)

assets/courses/
├── sachkundenachweis/questions.json
├── begleithund/questions.json
└── fibutroniker/questions.json
```

## Adding a New Course

1. Create `assets/courses/{course_id}/questions.json`.
2. Add a `Course(...)` entry in `lib/data/course_registry.dart`.
3. Add the asset path to `pubspec.yaml`.
4. Done — the app picks it up automatically.

## Local Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Source Material

- **Sachkundenachweis**: Official question catalog, Tierarztekammer Nordrhein.
- **Begleithundprüfung**: VDH-Prüfungsordnung (BH/VT).
- **FiButroniker**: IFU Institut für Bildung / ISM.
