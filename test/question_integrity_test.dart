// test/question_integrity_test.dart
// Tests question integrity for all courses: unique IDs, no gaps, each question
// has at least one correct answer and is assigned to a category.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:pruefungspilot/data/course_registry.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  for (final course in allCourses) {
    group('Integrity: ${course.title}', () {
      test('Questions are unique and contiguous from 1 to N', () async {
        final jsonString =
            await rootBundle.loadString(course.questionsAsset);
        final jsonList = json.decode(jsonString) as List<dynamic>;

        final ids = jsonList.map((q) => q['id'] as int).toList();
        final expected =
            List.generate(ids.length, (i) => i + 1).toSet();
        final found = ids.toSet();

        expect(found.difference(expected).isEmpty, true,
            reason: 'Unexpected IDs in "${course.id}"');
        expect(expected.difference(found).isEmpty, true,
            reason: 'Missing IDs in "${course.id}"');
      });

      test('Every question has at least one correct answer', () async {
        final jsonString =
            await rootBundle.loadString(course.questionsAsset);
        final jsonList = json.decode(jsonString) as List<dynamic>;

        for (final q in jsonList) {
          final correct = q['correctAnswers'] as List;
          expect(correct.isNotEmpty, true,
              reason:
                  'Question ${q['id']} in "${course.id}" has no correct answer.');
        }
      });

      test('Every question is assigned to a category', () async {
        final jsonString =
            await rootBundle.loadString(course.questionsAsset);
        final jsonList = json.decode(jsonString) as List<dynamic>;

        final allCategoryIds = course.questionCategories.values
            .expand((ids) => ids)
            .toSet();

        for (final q in jsonList) {
          final id = q['id'] as int;
          expect(allCategoryIds.contains(id), true,
              reason:
                  'Question $id in "${course.id}" is not assigned to any category.');
        }
      });
    });
  }
}
