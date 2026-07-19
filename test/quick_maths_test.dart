import 'package:flutter_test/flutter_test.dart';
import 'package:iambored/Games/QuickMaths/question_generator.dart';

/// Evaluates the rendered prompt ("7 × 8 = 54") independently of the generator
/// so the test can't inherit a bug from it.
bool _prompHolds(String text) {
  final parts = text.split(' ');
  expect(parts.length, 5, reason: 'unexpected prompt shape: $text');

  final a = int.parse(parts[0]);
  final b = int.parse(parts[2]);
  final shown = int.parse(parts[4]);

  switch (parts[1]) {
    case '+':
      return a + b == shown;
    case '-':
      return a - b == shown;
    case '×':
      return a * b == shown;
    case '÷':
      return a % b == 0 && a ~/ b == shown;
    default:
      fail('unknown operator in: $text');
  }
}

void main() {
  final generator = QuestionGenerator();

  // The tier boundaries live at 5, 12 and 20 answered questions.
  const samplePoints = [0, 3, 5, 9, 12, 17, 20, 40];

  test('isTrue always matches whether the displayed equation actually holds',
      () {
    for (final answered in samplePoints) {
      for (var i = 0; i < 1000; i++) {
        final q = generator.next(answered);
        expect(
          q.isTrue,
          _prompHolds(q.text),
          reason: 'mislabelled at tier point $answered: "${q.text}" '
              'claimed isTrue=${q.isTrue}',
        );
      }
    }
  });

  test('a decoy never collides with the real answer', () {
    for (var answer = 0; answer <= 225; answer++) {
      for (final op in Op.values) {
        for (var i = 0; i < 20; i++) {
          expect(generator.decoy(answer, op, 7, 8), isNot(answer),
              reason: 'decoy collided for answer=$answer op=$op');
        }
      }
    }
  });

  test('a decoy keeps the parity of the real answer, so parity gives no tell',
      () {
    for (var answer = 0; answer <= 225; answer++) {
      for (final op in Op.values) {
        for (var i = 0; i < 20; i++) {
          final d = generator.decoy(answer, op, 7, 8);
          expect(d % 2, answer % 2,
              reason: 'parity leak: answer=$answer decoy=$d op=$op');
          expect(d, greaterThanOrEqualTo(0));
        }
      }
    }
  });

  test('division prompts are always exact', () {
    for (var i = 0; i < 2000; i++) {
      final q = generator.next(15); // tier 2 is × and ÷ only
      final parts = q.text.split(' ');
      if (parts[1] == '÷') {
        expect(int.parse(parts[0]) % int.parse(parts[2]), 0);
      }
    }
  });

  test('subtraction prompts never go negative', () {
    for (var i = 0; i < 2000; i++) {
      final q = generator.next(i % 40);
      final parts = q.text.split(' ');
      if (parts[1] == '-') {
        expect(int.parse(parts[0]),
            greaterThanOrEqualTo(int.parse(parts[2])));
      }
    }
  });
}
