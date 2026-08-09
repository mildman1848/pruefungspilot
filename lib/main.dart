// Path: lib/main.dart
// Description: Main entry point of the multi-course learning platform.
// Navigation flow: Course Selection → Course (Dashboard / Quiz / Settings)
// Uses Riverpod for state management with the selectedCourseProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:io' show Platform;

import 'theme/theme_notifier.dart';
import 'providers/course_providers.dart';
import 'screens/course_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint(details.toString());
    }
  };

  if (Platform.isAndroid && !kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final currentTheme = themeNotifier.getThemeData(brightness);
    final darkTheme = themeNotifier.getThemeData(Brightness.dark);

    return MaterialApp(
      title: 'PrüfungsPilot',
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.materialThemeMode,
      home: const AppRoot(),
      builder: (context, child) => Semantics(child: child),
    );
  }
}

/// Root widget that switches between Course Selection and Course navigation.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCourse = ref.watch(selectedCourseProvider);

    if (selectedCourse == null) {
      return CourseSelectionScreen(
        onCourseSelected: (course) {
          // State is already updated in CourseSelectionScreen via provider.
        },
      );
    }

    return CourseNavigation(course: selectedCourse);
  }
}

/// In-course navigation with Dashboard, Quiz, and Settings tabs.
class CourseNavigation extends ConsumerStatefulWidget {
  const CourseNavigation({super.key});

  @override
  ConsumerState<CourseNavigation> createState() => _CourseNavigationState();
}

class _CourseNavigationState extends ConsumerState<CourseNavigation> {
  int _selectedIndex = 0;
  final _dashboard = const DashboardScreen();
  final _settings = const SettingsScreen();
  Widget? _currentQuizScreen;
  bool _quizLoading = false;

  Future<void> _loadQuizScreen() async {
    setState(() {
      _quizLoading = true;
    });
    _currentQuizScreen = const QuizScreen();
    setState(() {
      _quizLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentQuizScreen = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selectedIndex == 0) {
      content = _dashboard;
    } else if (_selectedIndex == 1) {
      if (_quizLoading) {
        content = const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (_currentQuizScreen != null) {
        content = _currentQuizScreen!;
      } else {
        _loadQuizScreen();
        content = const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    } else {
      content = _settings;
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) async {
          if (idx == 1) {
            await _loadQuizScreen();
          }
          setState(() {
            _selectedIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}
