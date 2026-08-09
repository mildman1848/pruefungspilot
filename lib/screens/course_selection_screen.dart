// Path: lib/screens/course_selection_screen.dart
// Description: Entry-point screen where the user selects which course to study.
// Shows all available courses as cards with icon, title, subtitle, and description.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/course_registry.dart';
import '../models/course_model.dart';
import '../providers/course_providers.dart';

class CourseSelectionScreen extends ConsumerStatefulWidget {
  final void Function(Course course)? onCourseSelected;

  const CourseSelectionScreen({super.key, this.onCourseSelected});

  @override
  ConsumerState<CourseSelectionScreen> createState() =>
      _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
  String? _lastUsedCourseId;

  @override
  void initState() {
    super.initState();
    _loadLastUsedCourse();
  }

  Future<void> _loadLastUsedCourse() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('last_used_course');
    if (mounted) {
      setState(() {
        _lastUsedCourseId = id;
      });
    }
  }

  Future<void> _selectCourse(Course course) async {
    // Persist last-used course for convenience.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_used_course', course.id);

    // Update Riverpod state.
    ref.read(selectedCourseIdProvider.notifier).state = course.id;

    // Notify parent via callback or pop.
    if (widget.onCourseSelected != null) {
      widget.onCourseSelected!(course);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernbereich wählen'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allCourses.length,
        itemBuilder: (context, index) {
          final course = allCourses[index];
          final isLastUsed = course.id == _lastUsedCourseId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Semantics(
                label: '${course.title}: ${course.subtitle}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _selectCourse(course),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Course icon in a colored circle.
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: course.primaryColor.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            course.icon,
                            size: 32,
                            color: course.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Title, subtitle, and description.
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      course.title,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (isLastUsed) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.history,
                                      size: 16,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: course.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Category count and estimated questions.
                              Row(
                                children: [
                                  Icon(Icons.category,
                                      size: 16,
                                      color: theme.colorScheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${course.categoryKeys.length} Kategorien',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.quiz,
                                      size: 16,
                                      color: theme.colorScheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '~${course.estimatedQuestionCount} Fragen',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Chevron.
                        Icon(
                          Icons.chevron_right,
                          color: course.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
