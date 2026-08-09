// Path: lib/screens/category_detail_screen.dart
// Description: Detail screen for a category with progress and navigation.
// Now course-aware: reads courseId from selectedCourseProvider.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_providers.dart';
import '../models/question_model.dart';
import '../storage/progress_storage.dart';
import 'single_question_screen.dart';
import 'category_learning_screen.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryKey;
  final String categoryTitle;
  final List<int> questionIds;

  const CategoryDetailScreen({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  late Future<List<_QuestionDetail>> _futureDetails;
  bool refreshRequested = false;

  @override
  void initState() {
    super.initState();
    _futureDetails = _loadDetails();
  }

  Future<List<_QuestionDetail>> _loadDetails() async {
    final courseId = ref.read(selectedCourseIdProvider);
    if (courseId == null) return [];

    final questionsData = await ref.read(questionsProvider.future);
    return Future.wait(widget.questionIds.map((id) async {
      final question =
          questionsData.firstWhere((q) => q.id == id, orElse: () => questionsData.first);
      final last3 =
          await ProgressStorage.getLastThreeResults(courseId, id);
      return _QuestionDetail(question: question, last3: last3);
    }));
  }

  Future<void> _openSingleQuestionScreen(int questionId) async {
    final refreshed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SingleQuestionScreen(questionId: questionId),
      ),
    );
    if (refreshed == true) {
      setState(() {
        _futureDetails = _loadDetails();
        refreshRequested = true;
      });
    }
  }

  Future<void> _openCategoryLearningScreen() async {
    final refreshed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryLearningScreen(
          categoryTitle: widget.categoryTitle,
          questionIds: widget.questionIds,
        ),
      ),
    );
    if (refreshed == true) {
      setState(() {
        _futureDetails = _loadDetails();
        refreshRequested = true;
      });
    }
  }

  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(refreshRequested);
    } else {
      Navigator.of(context).maybePop(refreshRequested);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          popWithRefresh();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kategorie: ${widget.categoryTitle}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: popWithRefresh,
            tooltip: "Zurück",
          ),
        ),
        body: FutureBuilder<List<_QuestionDetail>>(
          future: _futureDetails,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final details = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 18, left: 16, right: 16, bottom: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.playlist_play),
                    label: const Text("Lernmodus starten"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _openCategoryLearningScreen,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, idx) {
                      final detail = details[idx];
                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Semantics(
                          label:
                              'Frage ${detail.question.id}: ${detail.question.question}',
                          child: ListTile(
                            onTap: () async {
                              await _openSingleQuestionScreen(
                                  detail.question.id);
                            },
                            title: Text(
                              'Frage ${detail.question.id}: ${detail.question.question}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Row(
                              children: List.generate(3, (i) {
                                final state = detail.last3.length > i
                                    ? detail.last3[i]
                                    : null;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Icon(
                                    Icons.circle,
                                    size: 14,
                                    color: state == true
                                        ? Colors.green
                                        : (state == false
                                            ? Colors.red
                                            : Colors.grey.shade400),
                                  ),
                                );
                              }),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuestionDetail {
  final Question question;
  final List<bool> last3;

  _QuestionDetail({
    required this.question,
    required this.last3,
  });
}
