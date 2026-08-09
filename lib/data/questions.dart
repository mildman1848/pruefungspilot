// Path: lib/data/questions.dart
// Description: Compatibility shim — re-exports the course-aware questionsProvider.
// All new code should import from lib/providers/course_providers.dart directly.
//
// The questionsProvider now lives in course_providers.dart and is course-aware.
// This file ensures backward compatibility for tests and any legacy imports.

export '../providers/course_providers.dart' show questionsProvider;

import '../models/question_model.dart';

// Legacy fallback list (kept for tests only — not used at runtime anymore).
// Contains a few sample questions from the Sachkundenachweis catalog.
const List<Question> questionsFallback = [
  Question(
    id: 1,
    question: 'Was sind typische Jagdverhaltensweisen?',
    answers: [
      'Suchen nach Beute.',
      'Hetzen.',
      'Schütteln der Beute.',
      'Anschleichen und Vorstehen.',
    ],
    correctAnswers: [0, 1, 2, 3],
  ),
  Question(
    id: 2,
    question: 'Sind alle Hunde gleich oder gibt es rassetypische Eigenschaften?',
    answers: [
      'Alle Hunde sind gleich.',
      'Je nach Rasse weisen Hunde unterschiedliche Veranlagungen auf.',
      'Verschiedene Rassen unterscheiden sich nur durch ihr äußeres Erscheinungsbild.',
      'Rassetypische Eigenschaften gibt es nicht.',
    ],
    correctAnswers: [1],
  ),
];
