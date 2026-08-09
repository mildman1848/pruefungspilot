// Path: lib/screens/single_question_screen.dart
// Description: Single question screen with interactive answering and feedback.
// Now course-aware: reads courseId from selectedCourseProvider for progress storage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../providers/course_providers.dart';
import '../models/question_model.dart';
import '../storage/progress_storage.dart';

class SingleQuestionScreen extends ConsumerStatefulWidget {
  final int questionId;

  const SingleQuestionScreen({super.key, required this.questionId});

  @override
  ConsumerState<SingleQuestionScreen> createState() =>
      _SingleQuestionScreenState();
}

class _SingleQuestionScreenState extends ConsumerState<SingleQuestionScreen> {
  late Future<Question> _questionFuture;
  Set<int> selectedAnswers = {};
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    _questionFuture = _loadQuestion();
  }

  Future<Question> _loadQuestion() async {
    final questionsData = await ref.read(questionsProvider.future);
    return questionsData.firstWhere((qq) => qq.id == widget.questionId);
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

  Future<void> submitAnswer(Question q) async {
    final courseId = ref.read(selectedCourseIdProvider);
    setState(() {
      submitted = true;
    });
    if (courseId != null) {
      await ProgressStorage.addAnswerResult(
          courseId, q.id, isSelectionCorrect(selectedAnswers, q.correctAnswers));
    }
    Vibration.vibrate(
        pattern: isSelectionCorrect(selectedAnswers, q.correctAnswers)
            ? [0, 100]
            : [0, 500]);
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
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frage beantworten'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: popWithRefresh,
          tooltip: "Zurück",
        ),
      ),
      body: FutureBuilder<Question>(
        future: _questionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final q = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    icon: submitted
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.check),
                    label: Text(submitted ? "Zurück" : "Antwort prüfen"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: submitted
                        ? popWithRefresh
                        : (selectedAnswers.isEmpty
                            ? null
                            : () => submitAnswer(q)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
