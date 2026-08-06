// test/quiz_screen_test.dart
// Tests QuizScreen with course-aware providers.
// Sets selectedCourseIdProvider before testing so the questionsProvider loads data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lernapp/models/question_model.dart';
import 'package:lernapp/providers/course_providers.dart';
import 'package:lernapp/screens/quiz_screen.dart';
import 'package:lernapp/storage/progress_storage.dart';
import 'package:lernapp/theme/theme_notifier.dart';

void main() {
  group('QuizScreen Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Shows selected question correctly', (WidgetTester tester) async {
      const mockQuestion = Question(
        id: 1,
        question: 'Was sind typische Jagdverhaltensweisen?',
        answers: [
          'Suchen nach Beute.',
          'Hetzen.',
          'Schütteln der Beute.',
          'Anschleichen und Vorstehen.',
        ],
        correctAnswers: [0, 1, 2, 3],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            questionsProvider.overrideWith((ref) => Future.value([mockQuestion])),
            selectedCourseIdProvider.overrideWith((ref) => 'test_course'),
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: const MaterialApp(
            home: QuizScreen(singleQuestionId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.textContaining(mockQuestion.question), findsOneWidget);
      for (final answer in mockQuestion.answers) {
        expect(find.text(answer), findsOneWidget,
            reason: 'Answer "$answer" not found.');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Allows answer selection and saves result',
        (WidgetTester tester) async {
      const mockQuestion = Question(
        id: 1,
        question: 'Was sind typische Jagdverhaltensweisen?',
        answers: [
          'Suchen nach Beute.',
          'Hetzen.',
          'Schütteln der Beute.',
          'Anschleichen und Vorstehen.',
        ],
        correctAnswers: [0, 1, 2, 3],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            questionsProvider.overrideWith((ref) => Future.value([mockQuestion])),
            selectedCourseIdProvider.overrideWith((ref) => 'test_course'),
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: const MaterialApp(
            home: QuizScreen(singleQuestionId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Select all answers.
      for (final answer in mockQuestion.answers) {
        await tester.tap(find.text(answer));
        await tester.pump();
      }
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Submit.
      final submitButton = find.text('Antwort prüfen');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify progress was saved.
      final results =
          await ProgressStorage.getLastThreeResults('test_course', 1);
      expect(results, contains(true),
          reason: 'ProgressStorage should have saved the correct answer.');
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
