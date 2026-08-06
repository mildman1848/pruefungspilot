// Path: lib/screens/quiz_screen.dart
// Description: Quiz mode with randomized questions and feedback.
// Now course-aware: reads questions from the course-aware questionsProvider.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../providers/course_providers.dart';
import '../models/question_model.dart';
import '../models/course_model.dart';
import '../storage/progress_storage.dart';
import '../theme/theme_notifier.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.singleQuestionId});
  final int? singleQuestionId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Future<List<Question>> _shuffledQuestionsFuture;
  int currentIndex = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  bool loadingNext = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestionsFuture = _initQuiz();
  }

  Future<List<Question>> _initQuiz() async {
    final questionsData = await ref.read(questionsProvider.future);
    if (widget.singleQuestionId != null) {
      return [questionsData.firstWhere((q) => q.id == widget.singleQuestionId)];
    } else {
      return _buildPrioritizedShuffledQuestions(questionsData);
    }
  }

  List<Question> _buildPrioritizedShuffledQuestions(List<Question> data) {
    final weighted = <Question>[];
    for (final q in data) {
      weighted.addAll([q, q, q]);
    }
    weighted.shuffle(Random());
    final ids = <int>{};
    final result = <Question>[];
    for (final q in weighted) {
      if (!ids.contains(q.id)) {
        ids.add(q.id);
        result.add(q);
      }
    }
    return result;
  }

  Future<Question> getCurrentQuestion() async {
    final shuffled = await _shuffledQuestionsFuture;
    return shuffled[currentIndex];
  }

  Future<String?> getCurrentCategoryKey(Course course, Question q) async {
    for (final entry in course.questionCategories.entries) {
      if (entry.value.contains(q.id)) return entry.key;
    }
    return null;
  }

  Future<String> getCurrentCategoryTitle(Course course, Question q) async {
    final key = await getCurrentCategoryKey(course, q);
    return course.categoryTitles[key] ?? 'Unbekannt';
  }

  void toggleAnswer(int index) {
    if (submitted) return;
    setState(() {
      if (selectedAnswers.contains(index)) {
        selectedAnswers.remove(index);
      } else {
        selectedAnswers.add(index);
      }
    });
    Vibration.vibrate(duration: 50);
  }

  Future<void> submitAnswer() async {
    final question = await getCurrentQuestion();
    final courseId = ref.read(selectedCourseIdProvider);
    setState(() {
      submitted = true;
    });
    if (courseId != null) {
      await ProgressStorage.addAnswerResult(
          courseId, question.id, isSelectionCorrect(question));
    }
    Vibration.vibrate(
        pattern: isSelectionCorrect(question) ? [0, 100] : [0, 500]);
  }

  Future<void> nextQuestion() async {
    setState(() {
      loadingNext = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    final shuffled = await _shuffledQuestionsFuture;
    if (currentIndex < shuffled.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswers.clear();
        submitted = false;
        loadingNext = false;
      });
    } else {
      setState(() {
        loadingNext = false;
      });
    }
  }

  bool isCorrectAnswer(int index, List<int> correct) {
    return correct.contains(index);
  }

  bool isSelectionCorrect(Question q) {
    return Set.from(q.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(Set.from(q.correctAnswers));
  }

  void _cycleTheme() {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final current = ref.read(themeNotifierProvider).mode;
    const values = AppThemeMode.values;
    final next = values[(current.index + 1) % values.length];
    themeNotifier.setThemeMode(next);
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(selectedCourseProvider);

    return FutureBuilder<List<Question>>(
      future: _shuffledQuestionsFuture,
      builder: (context, shuffledSnapshot) {
        if (!shuffledSnapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final shuffled = shuffledSnapshot.data!;
        return FutureBuilder<Question>(
          future: getCurrentQuestion(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            final q = snapshot.data!;
            final secondary = Theme.of(context).colorScheme.secondary;

            return Scaffold(
              appBar: AppBar(
                title: FutureBuilder<String>(
                  future: course != null
                      ? getCurrentCategoryTitle(course, q)
                      : Future.value('Laden...'),
                  builder: (context, titleSnapshot) {
                    return Text(
                        "Kategorie: ${titleSnapshot.data ?? 'Laden...'}");
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.brightness_6),
                    tooltip: 'Theme wechseln',
                    onPressed: _cycleTheme,
                  )
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.singleQuestionId == null) ...[
                      LinearProgressIndicator(
                        value: (currentIndex + 1) / shuffled.length,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Frage ${currentIndex + 1} von ${shuffled.length}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Frage ${q.id}: ${q.question}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (q.image != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            q.image!,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(q.answers.length, (index) {
                            final isSelected =
                                selectedAnswers.contains(index);
                            final isCorrect =
                                isCorrectAnswer(index, q.correctAnswers);

                            Color? tileColor;
                            IconData? icon;
                            Color? iconColor;

                            if (submitted) {
                              if (isCorrect && isSelected) {
                                tileColor =
                                    Colors.green.withValues(alpha: 0.2);
                                icon = Icons.check_circle;
                                iconColor = Colors.green;
                              } else if (!isCorrect && isSelected) {
                                tileColor = Colors.red.withValues(alpha: 0.2);
                                icon = Icons.cancel;
                                iconColor = Colors.red;
                              } else if (isCorrect && !isSelected) {
                                tileColor =
                                    Colors.yellow.withValues(alpha: 0.2);
                                icon = Icons.warning_amber_rounded;
                                iconColor = Colors.orange;
                              }
                            } else if (isSelected) {
                              tileColor = secondary.withValues(alpha: 0.2);
                            }

                            return Semantics(
                              label: q.answers[index],
                              child: Card(
                                elevation: 2,
                                color: tileColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  onTap: () => toggleAnswer(index),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => toggleAnswer(index),
                                      activeColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    q.answers[index],
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  trailing: icon != null
                                      ? Icon(icon, color: iconColor)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: submitted
                            ? const Icon(Icons.arrow_forward)
                            : const Icon(Icons.check),
                        label: loadingNext
                            ? const Text("Lädt ...")
                            : (submitted
                                ? const Text("Nächste Frage")
                                : const Text("Antwort prüfen")),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        onPressed: loadingNext
                            ? null
                            : (submitted
                                ? nextQuestion
                                : (selectedAnswers.isEmpty
                                    ? null
                                    : submitAnswer)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
