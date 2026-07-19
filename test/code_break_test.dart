import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iambored/Games/CodeBreak/code_generator.dart';

/// Recounts feedback the slow, obvious way, independently of `evaluate`, so a
/// bug in the real implementation can't hide behind a test that shares it.
PegFeedback _bruteForce(List<int> guess, List<int> secret) {
  var black = 0;
  var white = 0;

  for (var i = 0; i < guess.length; i++) {
    if (guess[i] == secret[i]) {
      black++;
    } else if (secret.contains(guess[i])) {
      white++;
    }
  }

  return PegFeedback(black: black, white: white);
}

/// A random guess of 4 distinct colours - the only kind the UI can produce.
List<int> _randomGuess(Random random, Difficulty difficulty) {
  final palette = List<int>.generate(difficulty.paletteSize, (i) => i);
  palette.shuffle(random);
  return palette.take(CodeGenerator.codeLength).toList();
}

void main() {
  final generator = CodeGenerator(random: Random(42));
  final random = Random(7);

  test('a secret is always 4 distinct pegs from within the palette', () {
    for (final difficulty in Difficulty.values) {
      for (var i = 0; i < 2000; i++) {
        final secret = generator.generateSecret(difficulty);

        expect(secret.length, CodeGenerator.codeLength);
        expect(secret.toSet().length, CodeGenerator.codeLength,
            reason: 'duplicate colour in secret: $secret');
        for (final peg in secret) {
          expect(peg, greaterThanOrEqualTo(0));
          expect(peg, lessThan(difficulty.paletteSize));
        }
      }
    }
  });

  test('feedback matches an independent brute-force recount', () {
    for (final difficulty in Difficulty.values) {
      for (var i = 0; i < 3000; i++) {
        final secret = generator.generateSecret(difficulty);
        final guess = _randomGuess(random, difficulty);

        final actual = generator.evaluate(guess, secret);
        final expected = _bruteForce(guess, secret);

        expect(actual.black, expected.black,
            reason: 'black mismatch for guess=$guess secret=$secret');
        expect(actual.white, expected.white,
            reason: 'white mismatch for guess=$guess secret=$secret');
      }
    }
  });

  test('black + white never exceeds the code length', () {
    for (final difficulty in Difficulty.values) {
      for (var i = 0; i < 3000; i++) {
        final secret = generator.generateSecret(difficulty);
        final guess = _randomGuess(random, difficulty);
        final feedback = generator.evaluate(guess, secret);

        expect(feedback.black + feedback.white,
            lessThanOrEqualTo(CodeGenerator.codeLength));
        expect(feedback.black, greaterThanOrEqualTo(0));
        expect(feedback.white, greaterThanOrEqualTo(0));
      }
    }
  });

  test('solved is true if and only if the guess equals the secret', () {
    for (final difficulty in Difficulty.values) {
      for (var i = 0; i < 3000; i++) {
        final secret = generator.generateSecret(difficulty);
        final guess = _randomGuess(random, difficulty);

        final isExactMatch = guess.join(',') == secret.join(',');
        expect(generator.evaluate(guess, secret).solved, isExactMatch,
            reason: 'false win/loss for guess=$guess secret=$secret');
      }
    }
  });

  test('the secret against itself is a perfect score with no whites', () {
    for (final difficulty in Difficulty.values) {
      for (var i = 0; i < 500; i++) {
        final secret = generator.generateSecret(difficulty);
        final feedback = generator.evaluate(secret, secret);

        expect(feedback.black, CodeGenerator.codeLength);
        expect(feedback.white, 0);
        expect(feedback.solved, true);
      }
    }
  });

  test('overlap is counted, and a fully-shifted guess is all whites', () {
    // With a 7-colour palette two distinct 4-peg sets always share at least one
    // colour, so a genuinely disjoint guess is unreachable in the real game.
    // The reachable extreme is the right colours in entirely wrong slots.
    const secret = [0, 1, 2, 3];
    const rotated = [3, 0, 1, 2];

    final allWhite = generator.evaluate(rotated, secret);
    expect(allWhite.black, 0);
    expect(allWhite.white, CodeGenerator.codeLength);
    expect(allWhite.solved, false);

    // A guess sharing exactly one colour, in place.
    const oneBlack = [0, 4, 5, 6];
    final feedback = generator.evaluate(oneBlack, secret);
    expect(feedback.black, 1);
    expect(feedback.white, 0);
  });

  test('scoring rewards solving sooner and gives nothing for a loss', () {
    // Cracked on the first guess at Hard: (8 + 1 - 1) * 3
    expect(
      CodeGenerator.scoreFor(
          solved: true, guessesUsed: 1, difficulty: Difficulty.hard),
      24,
    );

    // Cracked on the fourth guess at Hard: (8 + 1 - 4) * 3
    expect(
      CodeGenerator.scoreFor(
          solved: true, guessesUsed: 4, difficulty: Difficulty.hard),
      15,
    );

    // Same guess count is worth less on an easier setting.
    expect(
      CodeGenerator.scoreFor(
          solved: true, guessesUsed: 4, difficulty: Difficulty.easy),
      5,
    );

    // Using every guess and still solving is worth the minimum, not zero.
    expect(
      CodeGenerator.scoreFor(
          solved: true, guessesUsed: 8, difficulty: Difficulty.easy),
      1,
    );

    // Failing scores nothing regardless of difficulty.
    for (final difficulty in Difficulty.values) {
      expect(
        CodeGenerator.scoreFor(
            solved: false, guessesUsed: 8, difficulty: difficulty),
        0,
      );
    }
  });
}
