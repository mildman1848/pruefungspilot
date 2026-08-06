// test/course_registry_test.dart
// Tests for the course registry — verifies all 3 courses are registered with
// correct structure, unique IDs, and valid category mappings.

import 'package:flutter_test/flutter_test.dart';
import 'package:lernapp/data/course_registry.dart';

void main() {
  group('Course Registry Tests', () {
    test('All 3 courses are registered', () {
      expect(allCourses.length, 3,
          reason: 'Expected exactly 3 courses in the registry.');
      expect(allCourses.map((c) => c.id).toSet(),
          {'sachkundenachweis', 'begleithund', 'fibutroniker'});
    });

    test('Each course has valid structure', () {
      for (final course in allCourses) {
        expect(course.id.isNotEmpty, true, reason: 'Course ID must not be empty.');
        expect(course.title.isNotEmpty, true, reason: 'Title must not be empty.');
        expect(course.questionsAsset.isNotEmpty, true,
            reason: 'questionsAsset must not be empty.');
        expect(course.categoryTitles.isNotEmpty, true,
            reason: 'Course "${course.id}" must have at least 1 category.');
        expect(course.questionCategories.isNotEmpty, true,
            reason: 'Course "${course.id}" must have questionCategories.');
      }
    });

    test('Each course has unique category keys', () {
      for (final course in allCourses) {
        final titleKeys = course.categoryTitles.keys.toSet();
        final questionCatKeys = course.questionCategories.keys.toSet();
        expect(titleKeys, questionCatKeys,
            reason:
                'Course "${course.id}": categoryTitles and questionCategories keys must match.');
      }
    });

    test('findCourseById returns correct course', () {
      expect(findCourseById('sachkundenachweis')?.title, 'Sachkundenachweis');
      expect(findCourseById('begleithund')?.title, 'Begleithundprüfung');
      expect(findCourseById('fibutroniker')?.title, 'FiButroniker');
      expect(findCourseById('nonexistent'), isNull);
    });

    test('estimatedQuestionCount > 0 for all courses', () {
      for (final course in allCourses) {
        expect(course.estimatedQuestionCount, greaterThan(0),
            reason: 'Course "${course.id}" should have questions.');
      }
    });
  });
}
