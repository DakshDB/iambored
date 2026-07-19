import 'package:flutter/material.dart';

import '../../Leaderboard/Services/ScoreRecorder.dart';
import 'code_generator.dart';

/// Colours a peg index maps to. Only the first `paletteSize` are ever used.
const List<Color> _pegColors = [
  Color(0xFFD32F2F), // red
  Color(0xFF1976D2), // blue
  Color(0xFF388E3C), // green
  Color(0xFFFBC02D), // yellow
  Color(0xFF7B1FA2), // purple
  Color(0xFFF57C00), // orange
  Color(0xFF5D4037), // brown
];

/// Each peg carries a letter as well as a colour. This is a game about telling
/// colours apart, so a colour-only palette would lock out players with colour
/// vision deficiency entirely rather than just making it harder for them.
const List<String> _pegLetters = ['R', 'B', 'G', 'Y', 'P', 'O', 'N'];

/// The worked example on the start screen: code R Y B G against a guess of
/// R B Y P, which scores one filled dot and two hollow ones.
const List<int> _exampleSecret = [0, 3, 1, 2];
const List<int> _exampleGuess = [0, 1, 3, 4];

class CodeBreak extends StatefulWidget {
  const CodeBreak({super.key});

  @override
  State<CodeBreak> createState() => _CodeBreakState();
}

class _CodeBreakState extends State<CodeBreak> {
  final CodeGenerator _generator = CodeGenerator();

  bool _isStart = false;
  bool _gameOver = false;
  bool _didSolve = false;

  Difficulty _difficulty = Difficulty.medium;
  List<int> _secret = [];
  List<List<int>> _guesses = [];
  List<PegFeedback> _feedback = [];
  List<int> _currentGuess = [];
  int _score = 0;

  void startGame(Difficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
      _secret = _generator.generateSecret(difficulty);
      _guesses = [];
      _feedback = [];
      _currentGuess = [];
      _score = 0;
      _gameOver = false;
      _didSolve = false;
      _isStart = true;
    });
  }

  void _pickColor(int colorIndex) {
    if (_gameOver) return;
    if (_currentGuess.length >= CodeGenerator.codeLength) return;
    // A colour can only appear once - the secret never repeats one, so a
    // repeated guess peg could never be right and would only waste a turn.
    if (_currentGuess.contains(colorIndex)) return;

    setState(() {
      _currentGuess.add(colorIndex);
    });
  }

  void _clearSlot(int slot) {
    if (_gameOver) return;
    if (slot >= _currentGuess.length) return;

    setState(() {
      _currentGuess.removeAt(slot);
    });
  }

  void _submitGuess() {
    if (_gameOver) return;
    if (_currentGuess.length != CodeGenerator.codeLength) return;

    final feedback = _generator.evaluate(_currentGuess, _secret);

    setState(() {
      _guesses.add(List<int>.from(_currentGuess));
      _feedback.add(feedback);
      _currentGuess = [];
    });

    if (feedback.solved) {
      _endGame(solved: true);
    } else if (_guesses.length >= CodeGenerator.maxGuesses) {
      _endGame(solved: false);
    }
  }

  void _endGame({required bool solved}) {
    final score = CodeGenerator.scoreFor(
      solved: solved,
      guessesUsed: _guesses.length,
      difficulty: _difficulty,
    );

    setState(() {
      _gameOver = true;
      _didSolve = solved;
      _score = score;
    });

    // Recorded once, at the end of the run - not per guess.
    recordScore('code_break', score.toDouble());
  }

  // ---------------------------------------------------------------- widgets

  Widget _peg(int? colorIndex, {double size = 36, VoidCallback? onTap}) {
    final filled = colorIndex != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? _pegColors[colorIndex] : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: filled
            ? Center(
                child: Text(
                  _pegLetters[colorIndex],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.42,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /// The feedback cluster: filled dots for exact matches, hollow dots for right
  /// colour in the wrong slot. Sorted, never aligned to the guess positions -
  /// if it lined up with the pegs it would give away *which* one was right and
  /// there would be nothing left to deduce.
  Widget _feedbackCluster(PegFeedback feedback) {
    final dots = <Widget>[];

    for (var i = 0; i < CodeGenerator.codeLength; i++) {
      final isBlack = i < feedback.black;
      final isWhite = i >= feedback.black && i < feedback.black + feedback.white;

      dots.add(Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBlack
                ? Colors.black
                : (isWhite ? Colors.white : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(
              color: (isBlack || isWhite) ? Colors.black : Colors.grey[350]!,
              width: 1,
            ),
          ),
        ),
      ));
    }

    return SizedBox(
      width: 40,
      child: Wrap(children: dots),
    );
  }

  /// A single score dot, used in the rules legend and the worked example so
  /// they match the real board exactly.
  Widget _scoreDot({required bool filled}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: filled ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  Widget _exampleRow(String label, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
          const SizedBox(width: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _guessRow(List<int> guess, PegFeedback feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final colorIndex in guess)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _peg(colorIndex),
            ),
          const SizedBox(width: 12),
          _feedbackCluster(feedback),
        ],
      ),
    );
  }

  Widget _currentGuessRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var slot = 0; slot < CodeGenerator.codeLength; slot++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _peg(
                slot < _currentGuess.length ? _currentGuess[slot] : null,
                onTap: () => _clearSlot(slot),
              ),
            ),
          const SizedBox(width: 12),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _palette() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < _difficulty.paletteSize; i++)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Opacity(
              // Used colours stay visible but read as unavailable.
              opacity: _currentGuess.contains(i) ? 0.25 : 1.0,
              child: _peg(i, size: 44, onTap: () => _pickColor(i)),
            ),
          ),
      ],
    );
  }

  Widget _blackButton(String label, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _outlinedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: const BorderSide(color: Colors.black))),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
      ),
      onPressed: onPressed,
      child: Text(label,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Code Break',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Crack the 4-colour code in 8 guesses',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 20),
                if (!_isStart) ..._startScreen(),
                if (_isStart) ..._gameScreen(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _startScreen() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[800],
                    ),
                children: const [
                  TextSpan(
                      text: "I've hidden 4 colours in a secret order. "),
                  TextSpan(
                    text: 'No colour repeats.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Make a guess and I'll score it with dots:",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 10),

            // Legend, using the same dots the board draws.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreDot(filled: true),
                const SizedBox(width: 8),
                Text('right colour, right place',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[800],
                        )),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreDot(filled: false),
                const SizedBox(width: 8),
                Text('right colour, wrong place',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[800],
                        )),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'The dots tell you how many, never which - they do not line up '
              'with your pegs.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 20),

            // A worked example does more than any amount of definition, and
            // it is the only way "the dots don't line up" really lands.
            Text(
              'Example',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _exampleRow('Code', [
              for (final i in _exampleSecret)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: _peg(i, size: 26),
                ),
            ]),
            _exampleRow('You guess', [
              for (final i in _exampleGuess)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: _peg(i, size: 26),
                ),
            ]),
            _exampleRow('Score', [
              _scoreDot(filled: true),
              const SizedBox(width: 6),
              _scoreDot(filled: false),
              const SizedBox(width: 6),
              _scoreDot(filled: false),
            ]),
            const SizedBox(height: 10),
            Text(
              'R is home. B and Y are in the code but misplaced. '
              'P is not in the code at all.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 20),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[800],
                    ),
                children: const [
                  TextSpan(
                    text: 'Count the dots',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: ' - that is how many of your colours are in the '
                          'code. Four dots means you already have the whole '
                          'set and only the order is wrong.'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      for (final difficulty in Difficulty.values) ...[
        _blackButton(
          '${difficulty.label}  -  ${difficulty.paletteSize} colours  '
          '(x${difficulty.multiplier})',
          () => startGame(difficulty),
        ),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 20),
      _outlinedButton('Back', () => Navigator.pop(context)),
    ];
  }

  List<Widget> _gameScreen() {
    final guessesLeft = CodeGenerator.maxGuesses - _guesses.length;

    return [
      Text(
        _gameOver
            ? 'Score: $_score'
            : 'Guesses left: $guessesLeft  -  ${_difficulty.label}',
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 18,
            ),
      ),
      const SizedBox(height: 20),

      for (var i = 0; i < _guesses.length; i++) _guessRow(_guesses[i], _feedback[i]),

      if (!_gameOver) _currentGuessRow(),

      if (_gameOver) ...[
        const SizedBox(height: 24),
        Text(
          _didSolve
              ? 'Cracked it in ${_guesses.length}!'
              : 'Out of guesses. The code was:',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final colorIndex in _secret)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _peg(colorIndex),
              ),
          ],
        ),
      ],

      const SizedBox(height: 24),

      if (!_gameOver) ...[
        // Held back until there is a scored guess to apply it to - before the
        // first guess it is just more to read.
        if (_guesses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Text(
              'Once you see 4 dots, stop changing colours. Swap two pegs and '
              'watch the filled-dot count.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        if (_guesses.isNotEmpty) const SizedBox(height: 20),
        _palette(),
        const SizedBox(height: 20),
        _blackButton(
          'Submit',
          _currentGuess.length == CodeGenerator.codeLength
              ? _submitGuess
              : null,
        ),
        const SizedBox(height: 20),
        _outlinedButton('Give Up', () => _endGame(solved: false)),
      ],

      if (_gameOver) ...[
        _blackButton('Play Again', () {
          setState(() {
            _isStart = false;
          });
        }),
        const SizedBox(height: 20),
        _outlinedButton('Back', () => Navigator.pop(context)),
      ],
    ];
  }
}
