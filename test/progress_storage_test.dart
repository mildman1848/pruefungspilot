// test/progress_storage_test.dart
// Tests ProgressStorage with course-aware namespacing.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lernapp/storage/progress_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressStorage Tests (course-aware)', () {
    test('Tracks last 3 answers and detects learned state', () async {
      const courseId = 'sachkundenachweis';
      const questionId = 42;

      await ProgressStorage.addAnswerResult(courseId, questionId, true);
      await ProgressStorage.addAnswerResult(courseId, questionId, false);
      await ProgressStorage.addAnswerResult(courseId, questionId, true);

      var results =
          await ProgressStorage.getLastThreeResults(courseId, questionId);
      expect(results, [true, false, true]);

      var learned = await ProgressStorage.isLearned(courseId, questionId);
      expect(learned, false);

      // 3x correct in a row.
      await ProgressStorage.addAnswerResult(courseId, questionId, true);
      await ProgressStorage.addAnswerResult(courseId, questionId, true);
      await ProgressStorage.addAnswerResult(courseId, questionId, true);

      results = await ProgressStorage.getLastThreeResults(courseId, questionId);
      expect(results, [true, true, true]);
      learned = await ProgressStorage.isLearned(courseId, questionId);
      expect(learned, true);

      // Reset.
      await ProgressStorage.resetProgress(courseId, questionId);
      results = await ProgressStorage.getLastThreeResults(courseId, questionId);
      expect(results, []);
    });

    test('Different courses have isolated progress', () async {
      const courseA = 'sachkundenachweis';
      const courseB = 'begleithund';
      const questionId = 1;

      // Set 3 correct for course A.
      await ProgressStorage.addAnswerResult(courseA, questionId, true);
      await ProgressStorage.addAnswerResult(courseA, questionId, true);
      await ProgressStorage.addAnswerResult(courseA, questionId, true);

      // Course B should still be empty.
      final resultsB =
          await ProgressStorage.getLastThreeResults(courseB, questionId);
      expect(resultsB, []);

      // Course A should be learned.
      final learnedA =
          await ProgressStorage.isLearned(courseA, questionId);
      expect(learnedA, true);

      // Course B should not be learned.
      final learnedB =
          await ProgressStorage.isLearned(courseB, questionId);
      expect(learnedB, false);
    });

    test('Handles multiple questions within a course', () async {
      const courseId = 'fibutroniker';

      await ProgressStorage.addAnswerResult(courseId, 1, true);
      await ProgressStorage.addAnswerResult(courseId, 1, true);
      await ProgressStorage.addAnswerResult(courseId, 2, false);

      final results1 =
          await ProgressStorage.getLastThreeResults(courseId, 1);
      expect(results1, [true, true]);

      final results2 =
          await ProgressStorage.getLastThreeResults(courseId, 2);
      expect(results2, [false]);
    });
  });
}
