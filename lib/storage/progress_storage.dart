// Path: lib/storage/progress_storage.dart
// Description: Storage and management of learning progress with SharedPreferences.
// All keys are namespaced by courseId to support the multi-course platform.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/course_providers.dart';

class ProgressStorage {
  static const String _prefix = 'question_'; // Prefix pattern: {courseId}_question_{id}_last3

  /// SharedPreferences key for a specific question's progress within a course.
  static String _key(String courseId, int questionId) {
    return '${courseId}_${_prefix}${questionId}_last3';
  }

  /// Returns the last 3 answer results as a list of bool (true = correct).
  static Future<List<bool>> getLastThreeResults(String courseId, int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(courseId, questionId)) ?? [];
    return raw.map((e) => e == '1').toList();
  }

  /// Adds the result of the current answer (true = correct, false = wrong).
  static Future<void> addAnswerResult(String courseId, int questionId, bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(courseId, questionId)) ?? [];
    final results = raw.map((e) => e == '1').toList();
    results.insert(0, isCorrect); // Newest first (FIFO for last 3).
    if (results.length > 3) results.length = 3;
    final saveList = results.map((e) => e ? '1' : '0').toList();
    await prefs.setStringList(_key(courseId, questionId), saveList);
  }

  /// Resets progress for a single question.
  static Future<void> resetProgress(String courseId, int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(courseId, questionId));
  }

  /// Resets progress for all questions in the current course.
  static Future<void> resetAllProgress(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final questionsData = await ref.read(questionsProvider.future);
    final courseId = ref.read(selectedCourseIdProvider);
    if (courseId == null) return;
    for (final q in questionsData) {
      await prefs.remove(_key(courseId, q.id));
    }
  }

  /// Returns whether a question is learned (3 correct in a row).
  static Future<bool> isLearned(String courseId, int questionId) async {
    final results = await getLastThreeResults(courseId, questionId);
    return results.length == 3 && results.every((e) => e);
  }

  /// Returns how many questions in the current course are learned (3x correct in a row).
  static Future<int> getTotalLearnedCount(WidgetRef ref) async {
    int count = 0;
    final questionsData = await ref.read(questionsProvider.future);
    final courseId = ref.read(selectedCourseIdProvider);
    if (courseId == null) return 0;
    for (final q in questionsData) {
      if (await isLearned(courseId, q.id)) count++;
    }
    return count;
  }
}
