// Path: lib/models/course_model.dart
// Description: Course model for the multi-course learning platform.
// Each course represents a certification/exam that the user can study for.
// Plain Dart class (not Freezed) since courses are static registry data.

import 'package:flutter/material.dart';

/// Represents a single study course (e.g. Sachkundenachweis, Begleithund, FiButroniker).
class Course {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final String questionsAsset;

  /// Category key → human-readable title
  final Map<String, String> categoryTitles;

  /// Category key → list of question IDs belonging to that category
  final Map<String, List<int>> questionCategories;

  /// Ordered list of category keys (derived from categoryTitles for determinism)
  List<String> get categoryKeys => categoryTitles.keys.toList();

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.questionsAsset,
    required this.categoryTitles,
    required this.questionCategories,
  });

  /// Total number of questions in this course (max ID, not deduplicated count).
  /// The actual count is determined at runtime from the JSON.
  int get estimatedQuestionCount =>
      questionCategories.values.expand((ids) => ids).toSet().length;
}
