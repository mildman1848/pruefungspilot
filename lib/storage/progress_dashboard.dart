// Path: lib/storage/progress_dashboard.dart
// Description: Helper functions for progress calculations per category and global.
// Now fully course-aware: uses selectedCourseProvider for all lookups.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_providers.dart';
import '../models/course_model.dart';
import '../storage/progress_storage.dart';

/// Helper: Find the category key for a question ID within a given course.
String? getCategoryKeyForQuestion(Course course, int questionId) {
  for (final entry in course.questionCategories.entries) {
    if (entry.value.contains(questionId)) return entry.key;
  }
  return null;
}

class ProgressDashboard {
  /// Returns how many questions are learned per category (last 3 correct).
  static Future<Map<String, int>> getLearnedCountByCategory(WidgetRef ref) async {
    final course = ref.read(selectedCourseProvider);
    if (course == null) return {};

    final courseId = course.id;
    final Map<String, int> categoryCounts = {};

    // Initialize every category with 0.
    for (final catKey in course.categoryKeys) {
      categoryCounts[catKey] = 0;
    }

    final questionsData = await ref.read(questionsProvider.future);

    for (final q in questionsData) {
      if (await ProgressStorage.isLearned(courseId, q.id)) {
        final catKey = getCategoryKeyForQuestion(course, q.id);
        if (catKey != null) {
          categoryCounts[catKey] = (categoryCounts[catKey]! + 1);
        }
      }
    }
    return categoryCounts;
  }

  /// Returns how many questions are learned in total (last 3 correct).
  static Future<int> getTotalLearnedCount(WidgetRef ref) async {
    final course = ref.read(selectedCourseProvider);
    if (course == null) return 0;

    final courseId = course.id;
    final questionsData = await ref.read(questionsProvider.future);

    int count = 0;
    for (final q in questionsData) {
      if (await ProgressStorage.isLearned(courseId, q.id)) count++;
    }
    return count;
  }

  /// Returns the total number of questions in the current course.
  static Future<int> getTotalQuestionCount(WidgetRef ref) async {
    final questionsData = await ref.read(questionsProvider.future);
    return questionsData.length;
  }
}
