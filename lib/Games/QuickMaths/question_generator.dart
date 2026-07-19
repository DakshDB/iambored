import 'dart:math';

enum Op { add, sub, mul, div }

class Question {
  final String text;
  final bool isTrue;

  const Question({required this.text, required this.isTrue});
}

/// Builds the true/false arithmetic prompts for Quick Maths.
///
/// Kept out of the widget so the decoy logic can be exercised directly - a
/// decoy that collides with the real answer produces a question labelled
/// "false" that is actually true, and with sudden death that ends a run
/// through no fault of the player.
class QuestionGenerator {
  final Random _random;

  QuestionGenerator({Random? random}) : _random = random ?? Random();

  Question next(int questionsAnswered) {
    final tier = tierFor(questionsAnswered);
    final ops = _ops(tier);
    final op = ops[_random.nextInt(ops.length)];

    final int a, b, answer;
    switch (op) {
      case Op.add:
        {
          final max = tier == 0 ? 20 : (tier == 1 ? 50 : 99);
          a = 1 + _random.nextInt(max);
          b = 1 + _random.nextInt(max);
          answer = a + b;
        }
        break;
      case Op.sub:
        {
          final max = tier == 0 ? 20 : (tier == 1 ? 50 : 99);
          final x = 1 + _random.nextInt(max);
          final y = 1 + _random.nextInt(max);
          // Keep the result non-negative so the prompt stays readable.
          a = x >= y ? x : y;
          b = x >= y ? y : x;
          answer = a - b;
        }
        break;
      case Op.mul:
        {
          final max = tier == 1 ? 9 : (tier == 2 ? 12 : 15);
          a = 2 + _random.nextInt(max - 1);
          b = 2 + _random.nextInt(max - 1);
          answer = a * b;
        }
        break;
      case Op.div:
        {
          // Generated backwards from the answer so the division is exact.
          final max = tier == 2 ? 12 : 15;
          b = 2 + _random.nextInt(max - 1);
          answer = 2 + _random.nextInt(max - 1);
          a = b * answer;
        }
        break;
    }

    final showTrue = _random.nextBool();
    final shown = showTrue ? answer : decoy(answer, op, a, b);

    return Question(
      text: '$a ${_symbol(op)} $b = $shown',
      isTrue: shown == answer,
    );
  }

  int tierFor(int questionsAnswered) {
    if (questionsAnswered < 5) return 0;
    if (questionsAnswered < 12) return 1;
    if (questionsAnswered < 20) return 2;
    return 3;
  }

  List<Op> _ops(int tier) {
    switch (tier) {
      case 0:
        return [Op.add, Op.sub];
      case 1:
        return [Op.add, Op.sub, Op.mul];
      case 2:
        return [Op.mul, Op.div];
      default:
        return [Op.add, Op.sub, Op.mul, Op.div];
    }
  }

  String _symbol(Op op) {
    switch (op) {
      case Op.add:
        return '+';
      case Op.sub:
        return '-';
      case Op.mul:
        return '×';
      case Op.div:
        return '÷';
    }
  }

  /// A wrong answer that still looks plausible.
  ///
  /// Every candidate keeps the parity of the real answer. Parity is otherwise a
  /// free win: 7 × 9 must be odd, so a decoy of 64 can be rejected on sight
  /// without doing any multiplication. That rules out the classic off-by-one,
  /// but ±2, ±10 and the adjacent-multiple decoys stay convincing under time
  /// pressure.
  int decoy(int answer, Op op, int a, int b) {
    final candidates = <int>[
      answer + 2,
      answer - 2,
      answer + 10,
      answer - 10,
    ];

    if (op == Op.mul) {
      // Lands on a neighbouring entry in the same times table (7 × 8 -> 49, 63),
      // which is the most believable miss available.
      candidates.addAll([answer + a, answer - a, answer + b, answer - b]);
    }

    final swapped = _transposeDigits(answer);
    if (swapped != null) candidates.add(swapped);

    final valid = candidates
        .where((c) => c != answer && c >= 0 && c % 2 == answer % 2)
        .toList();

    if (valid.isEmpty) return answer + 4;
    return valid[_random.nextInt(valid.length)];
  }

  /// Swaps the leading two digits (54 -> 45). Null when that is not a distinct,
  /// well-formed number.
  int? _transposeDigits(int value) {
    final digits = value.toString().split('');
    if (digits.length < 2) return null;

    final first = digits[0];
    digits[0] = digits[1];
    digits[1] = first;
    if (digits[0] == '0') return null;

    final swapped = int.parse(digits.join());
    return swapped == value ? null : swapped;
  }
}
