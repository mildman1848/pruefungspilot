// Path: lib/providers/course_providers.dart
// Description: Central Riverpod providers for the multi-course learning platform.
// All course-aware logic flows through selectedCourseProvider.

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/course_model.dart';
import '../models/question_model.dart';
import '../data/course_registry.dart';

// ─── Selected Course ──────────────────────────────────────────────────────

/// The currently selected course ID. null = no course selected (shows course selection screen).
final selectedCourseIdProvider = StateProvider<String?>((ref) => null);

/// The currently selected Course object, derived from the ID.
final selectedCourseProvider = Provider<Course?>((ref) {
  final id = ref.watch(selectedCourseIdProvider);
  if (id == null) return null;
  return findCourseById(id);
});

// ─── Questions Provider (course-aware) ────────────────────────────────────

/// Loads questions for the currently selected course.
/// Returns an empty list if no course is selected (shouldn't happen in practice).
final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final course = ref.watch(selectedCourseProvider);
  if (course == null) return [];

  final jsonString = await rootBundle.loadString(course.questionsAsset);
  final jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList.map((json) => Question.fromJson(json)).toList();
});
