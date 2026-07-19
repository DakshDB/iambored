import 'dart:math';

/// Difficulty controls how many colours the secret is drawn from, and how much
/// a win is worth. A wider palette means more possible codes to eliminate.
enum Difficulty { easy, medium, hard }

extension DifficultyProperties on Difficulty {
  /// How many colours are available to choose from.
  int get paletteSize {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 6;
      case Difficulty.hard:
        return 7;
    }
  }

  /// Score multiplier applied to the remaining-guess bonus.
  int get multiplier {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

/// The result of comparing a guess against the secret.
///
/// Deliberately carries no positional information - the player learns *how
/// many* pegs are right, never *which*. That ambiguity is the whole game.
/// Named `PegFeedback` rather than `Feedback` because Flutter's material
/// library already exports a `Feedback` class for haptics.
class PegFeedback {
  /// Right colour in the right slot.
  final int black;

  /// Right colour in the wrong slot.
  final int white;

  const PegFeedback({required this.black, required this.white});

  bool get solved => black == CodeGenerator.codeLength;
}

class CodeGenerator {
  /// Pegs in a code. Fixed at 4 - the palette size is what varies.
  static const int codeLength = 4;

  /// Guesses allowed before the run ends.
  static const int maxGuesses = 8;

  final Random _random;

  CodeGenerator({Random? random}) : _random = random ?? Random();

  /// Picks [codeLength] distinct colour indices from the difficulty's palette.
  ///
  /// Shuffle-and-take rather than rejection sampling, so distinctness holds by
  /// construction and the method can never loop.
  List<int> generateSecret(Difficulty difficulty) {
    final palette = List<int>.generate(difficulty.paletteSize, (i) => i);
    palette.shuffle(_random);
    return palette.take(codeLength).toList();
  }

  /// Compares [guess] against [secret].
  ///
  /// Both are guaranteed to hold distinct values (the secret by construction,
  /// the guess because the UI won't let a colour be used twice), so the counts
  /// need none of the duplicate-handling that classic Mastermind requires:
  /// every shared colour is shared exactly once.
  PegFeedback evaluate(List<int> guess, List<int> secret) {
    var black = 0;
    for (var i = 0; i < secret.length; i++) {
      if (guess[i] == secret[i]) black++;
    }

    final common = guess.toSet().intersection(secret.toSet()).length;
    return PegFeedback(black: black, white: common - black);
  }

  /// Score for a finished run. Solving sooner is worth more; failing to crack
  /// the code is worth nothing at all, whatever the difficulty.
  static int scoreFor({
    required bool solved,
    required int guessesUsed,
    required Difficulty difficulty,
  }) {
    if (!solved) return 0;
    return (maxGuesses + 1 - guessesUsed) * difficulty.multiplier;
  }
}
