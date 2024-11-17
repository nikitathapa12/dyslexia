import 'dart:math';
import 'package:dyslearn/Games/counting_number/CountingNumber.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CherryCountingGame extends StatefulWidget {
  @override
  _CherryCountingGameState createState() => _CherryCountingGameState();
}

class _CherryCountingGameState extends State<CherryCountingGame> with TickerProviderStateMixin {
  int correctNumber = 0;
  int score = 0;
  int lastScore = 0;
  int roundsPlayed = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _showHint = false;
  String countdown = '';
  List<AnimationController> _bounceControllers = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _scoreAnimationController;

  @override
  void initState() {
    super.initState();
    _generateNewRound();

    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _generateNewRound() {
    setState(() {
      lastScore = score;
      correctNumber = Random().nextInt(9) + 1;
      _isAnswered = false;
      _isCorrect = false;
      countdown = '';
      _showHint = false;
      _initializeBounceControllers();
    });
  }

  void _initializeBounceControllers() {
    _bounceControllers.forEach((controller) => controller.dispose());
    _bounceControllers = List.generate(correctNumber, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        lowerBound: 0.8,
        upperBound: 1.2,
      );
    });
  }

  void _handleOptionSelected(int selectedNumber) async {
    if (selectedNumber == correctNumber) {
      setState(() {
        _isAnswered = true;
        _isCorrect = true;
        score++;
        _scoreAnimationController.forward(from: 0);
      });
      await _playCorrectSound();
      _startCountdown();
    } else {
      setState(() {
        _isAnswered = true;
        _isCorrect = false;
      });
      await _playIncorrectSound();
      _generateNewRound();
    }
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('audio/correct.mp3'));
  }

  Future<void> _playIncorrectSound() async {
    await _audioPlayer.play(AssetSource('audio/incorrect.mp3'));
  }

  void _startCountdown() async {
    for (int i = 1; i <= correctNumber; i++) {
      await Future.delayed(Duration(seconds: 1));
      _playNumberSound(i);
      _bounceControllers[i - 1].forward(from: 0);
      setState(() {
        countdown += '$i ';
      });
    }
    await Future.delayed(Duration(seconds: 1));
    _checkGameCompletion();
  }

  void _playNumberSound(int number) async {
    await _audioPlayer.play(AssetSource('audio/$number.mp3'));
  }

  void _checkGameCompletion() {
    roundsPlayed++;
    if (roundsPlayed >= 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CountingGame()),
      );
    } else {
      _generateNewRound();
    }
  }

  void _showHintMessage() {
    setState(() {
      _showHint = true;
    });
  }

  Widget _buildCherries() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.center,
          children: List.generate(correctNumber, (index) {
            return ScaleTransition(
              scale: _bounceControllers[index],
              child: Image.asset(
                'assets/images/cherry.png',
                height: 60,
                width: 60,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    List<int> options = [];
    options.add(correctNumber);

    while (options.length < 4) {
      int randomOption = Random().nextInt(9) + 1;
      if (!options.contains(randomOption)) {
        options.add(randomOption);
      }
    }

    options.shuffle();

    return Column(
      children: [
        Text(
          'How many cherries are there?',
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'OpenDyslexic',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            int option = options[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _isAnswered ? null : () => _handleOptionSelected(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade300,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black54,
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    '$option',
                    key: ValueKey<int>(option),
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: 'OpenDyslexic',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    if (_isAnswered) {
      return _isCorrect
          ? Text(
        'Correct!',
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      )
          : Text(
        'Wrong! Try again.',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Container();
  }

  Widget _buildCountdown() {
    return Text(
      countdown,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildScore() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _scoreAnimationController,
          builder: (context, child) {
            double animatedValue = _scoreAnimationController.value;
            return Transform.scale(
              scale: 1.0 + (animatedValue * 0.3),
              child: Column(
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade300,
                      fontFamily: 'OpenDyslexic',
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Last Score: $lastScore',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontFamily: 'OpenDyslexic',
                    ),
                  ),
                  if (_showHint)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Hint: The correct number is $correctNumber!',
                        style: TextStyle(color: Colors.yellowAccent, fontSize: 18),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.lightbulb_outline, color: Colors.blue),
          onPressed: _showHint ? null : _showHintMessage,
          tooltip: 'Hint',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cherry Counting Game',
          style: TextStyle(fontFamily: 'OpenDyslexic'),
        ),
        backgroundColor: Colors.deepPurple.shade300,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.brown.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScore(),
                SizedBox(height: 20),
                _buildCherries(),
                SizedBox(height: 10),
                _buildOptions(),
                SizedBox(height: 20),
                _buildFeedback(),
                SizedBox(height: 10),
                _buildCountdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
