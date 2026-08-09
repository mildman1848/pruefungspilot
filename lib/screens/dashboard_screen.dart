// Path: lib/screens/dashboard_screen.dart
// Description: Dashboard showing learning progress per category and global.
// Now course-aware: reads the selected course from selectedCourseProvider.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_providers.dart';
import '../storage/progress_dashboard.dart';
import 'category_detail_screen.dart';
import '../widgets/global_progress_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  Map<String, int> learnedByCategory = {};
  Map<String, int> totalByCategory = {};
  bool loading = true;

  int globalLearned = 0;
  int globalTotal = 0;
  double globalPercent = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadProgress();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProgress();
  }

  Future<void> loadProgress() async {
    setState(() {
      loading = true;
    });

    final course = ref.read(selectedCourseProvider);
    if (course == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final byCategory = await ProgressDashboard.getLearnedCountByCategory(ref);
    final totalPerCat = <String, int>{};
    for (final catKey in course.categoryKeys) {
      totalPerCat[catKey] = course.questionCategories[catKey]?.length ?? 0;
    }

    final learnedGlobal = await ProgressDashboard.getTotalLearnedCount(ref);
    final totalGlobal = await ProgressDashboard.getTotalQuestionCount(ref);
    final percentGlobal = totalGlobal == 0 ? 0.0 : learnedGlobal / totalGlobal;

    if (mounted) {
      setState(() {
        learnedByCategory = byCategory;
        totalByCategory = totalPerCat;
        globalLearned = learnedGlobal;
        globalTotal = totalGlobal;
        globalPercent = percentGlobal;
        loading = false;
      });
    }
  }

  int get finishedCategoriesCount {
    int count = 0;
    for (final catKey in totalByCategory.keys) {
      final learned = learnedByCategory[catKey] ?? 0;
      final total = totalByCategory[catKey] ?? 0;
      if (total > 0 && learned == total) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final course = ref.watch(selectedCourseProvider);
    if (course == null) {
      return const Scaffold(body: Center(child: Text('Kein Kurs ausgewählt.')));
    }

    final categories = course.categoryKeys;
    final catTitles = course.categoryTitles;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : screenWidth > 400
                ? 2
                : 1;

    final colorScheme = Theme.of(context).colorScheme;
    final secondary = colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Aktualisieren",
            onPressed: loadProgress,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlobalProgressCard(
              percent: globalPercent,
              learned: globalLearned,
              total: globalTotal,
              finishedCategories: finishedCategoriesCount,
              totalCategories: totalByCategory.length,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final catKey = categories[index];
                  final learned = learnedByCategory[catKey] ?? 0;
                  final total = totalByCategory[catKey] ?? 0;
                  final percent = total > 0 ? (learned / total).clamp(0.0, 1.0) : 0.0;

                  final Color backgroundColor = secondary.withValues(alpha: 0.15);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Semantics(
                      label: catTitles[catKey] ?? catKey,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final ids = course.questionCategories[catKey] ?? [];
                          final title = catTitles[catKey] ?? catKey;
                          final refreshed = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                categoryKey: catKey,
                                categoryTitle: title,
                                questionIds: ids,
                              ),
                            ),
                          );
                          if (refreshed == true) {
                            loadProgress();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catTitles[catKey] ?? catKey,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                "$learned von $total gelernt",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 12,
                                  backgroundColor: backgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percent >= 1.0 ? Colors.green : secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
