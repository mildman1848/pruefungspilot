// Path: lib/screens/category_learning_screen.dart
// Description: Learning mode for a category with interactive questions.
// Now course-aware: reads courseId from selectedCourseProvider for progress storage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../providers/course_providers.dart';
import '../models/question_model.dart';
import '../storage/progress_storage.dart';
import '../theme/theme_notifier.dart';

class CategoryLearningScreen extends ConsumerStatefulWidget {
  final String categoryTitle;
  final List<int> questionIds;

  const CategoryLearningScreen({
    super.key,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  ConsumerState<CategoryLearningScreen> createState() =>
      _CategoryLearningScreenState();
}

class _CategoryLearningScreenState extends ConsumerState<CategoryLearningScreen> {
  int currentIdx = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  bool finished = false;

  Future<Question> getCurrentQuestion() async {
    final questionsData = await ref.read(questionsProvider.future);
    return questionsData.firstWhere(
        (q) => q.id == widget.questionIds[currentIdx]);
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

  bool isCorrectAnswer(int index, List<int> correct) {
    return correct.contains(index);
  }

  bool isSelectionCorrect(Set<int> selected, List<int> correct) {
    return Set.from(correct).containsAll(selected) &&
        selected.containsAll(Set.from(correct));
  }

  Future<void> submitAnswer() async {
    final question = await getCurrentQuestion();
    final courseId = ref.read(selectedCourseIdProvider);
    final correct = isSelectionCorrect(selectedAnswers, question.correctAnswers);
    setState(() {
      submitted = true;
    });
    if (courseId != null) {
      await ProgressStorage.addAnswerResult(courseId, question.id, correct);
    }
    Vibration.vibrate(pattern: correct ? [0, 100] : [0, 500]);
  }

  Future<void> nextQuestion() async {
    if (currentIdx < widget.questionIds.length - 1) {
      setState(() {
        currentIdx++;
        selectedAnswers.clear();
        submitted = false;
      });
    } else {
      setState(() {
        finished = true;
      });
    }
  }

  void _cycleTheme() {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final current = ref.read(themeNotifierProvider).mode;
    const values = AppThemeMode.values;
    final next = values[(current.index + 1) % values.length];
    themeNotifier.setThemeMode(next);
  }

  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Lernmodus: ${widget.categoryTitle}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: popWithRefresh,
            tooltip: "Zurück",
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 18),
              Text(
                "Super, du hast alle Fragen dieser Kategorie durchgearbeitet!",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Zurück zur Kategorie"),
                onPressed: popWithRefresh,
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Question>(
      future: getCurrentQuestion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final q = snapshot.data!;
        final Color secondary = Theme.of(context).colorScheme.secondary;

        return Scaffold(
          appBar: AppBar(
            title: Text("Lernmodus: ${widget.categoryTitle}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Theme wechseln',
                onPressed: _cycleTheme,
              )
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: popWithRefresh,
              tooltip: "Zurück",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (currentIdx + 1) / widget.questionIds.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Frage ${currentIdx + 1} von ${widget.questionIds.length}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
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
                        final isSelected = selectedAnswers.contains(index);
                        final isCorrect =
                            isCorrectAnswer(index, q.correctAnswers);

                        Color? tileColor;
                        IconData? icon;
                        Color? iconColor;

                        if (submitted) {
                          if (isCorrect && isSelected) {
                            tileColor = Colors.green.withValues(alpha: 0.2);
                            icon = Icons.check_circle;
                            iconColor = Colors.green;
                          } else if (!isCorrect && isSelected) {
                            tileColor = Colors.red.withValues(alpha: 0.2);
                            icon = Icons.cancel;
                            iconColor = Colors.red;
                          } else if (isCorrect && !isSelected) {
                            tileColor = Colors.yellow.withValues(alpha: 0.2);
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
                    icon: Icon(
                      finished
                          ? Icons.check_circle
                          : (submitted ? Icons.arrow_forward : Icons.check),
                    ),
                    label: finished
                        ? const Text("Fertig")
                        : (submitted
                            ? const Text("Nächste Frage")
                            : const Text("Antwort prüfen")),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: finished
                        ? popWithRefresh
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
  }
}
