// test/question_model_test.dart
// Tests the Question model initialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:pruefungspilot/models/question_model.dart';

void main() {
  group('Question Model Tests', () {
    test('Question model initializes correctly', () {
      const question = Question(
        id: 1,
        question: 'Wie viele Beine hat ein Hund?',
        answers: ['Zwei', 'Drei', 'Vier', 'Fünf'],
        correctAnswers: [2],
        image: 'assets/images/sketches/1.png',
      );

      expect(question.id, 1);
      expect(question.question, 'Wie viele Beine hat ein Hund?');
      expect(question.answers[2], 'Vier');
      expect(question.correctAnswers, [2]);
      expect(question.image, isNotNull);
    });

    test('Question model works without image (null)', () {
      const question = Question(
        id: 99,
        question: 'Test question without image?',
        answers: ['Yes', 'No'],
        correctAnswers: [0],
      );

      expect(question.id, 99);
      expect(question.image, isNull);
    });
  });
}
