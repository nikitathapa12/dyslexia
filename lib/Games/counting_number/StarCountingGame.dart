import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class StarCountingGame extends StatefulWidget {
  @override
  _StarCountingGameState createState() => _StarCountingGameState();
}

class _StarCountingGameState extends State<StarCountingGame> with TickerProviderStateMixin {
  int correctNumber = 0;
  int score = 0;
  int lastScore = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String countdown = '';
  String hintText = '';
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
      lastScore = score; // Update lastScore at the start of a new round
      correctNumber = Random().nextInt(9) + 1;
      _isAnswered = false;
      _isCorrect = false;
      countdown = '';
      hintText = ''; // Reset hint text for each new round
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

  void _handleOptionSelected(int selectedNumber) {
    if (selectedNumber == correctNumber) {
      setState(() {
        _isAnswered = true;
        _isCorrect = true;
        lastScore=score;
        score++;
        _scoreAnimationController.forward(from: 0);
      });
      _startCountdown();
    } else {
      setState(() {
        _isAnswered = true;
        _isCorrect = false;
      });
      _generateNewRound();
    }
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
    _generateNewRound();
  }

  void _playNumberSound(int number) async {
    await _audioPlayer.play(AssetSource('audio/$number.mp3'));
  }

  Widget _buildStars() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      alignment: WrapAlignment.center,
      children: List.generate(correctNumber, (index) {
        return ScaleTransition(
          scale: _bounceControllers[index],
          child: Image.asset(
            'assets/images/star.png',
            height: 60,
            width: 60,
          ),
        );
      }),
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
          'How many stars are there?',
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
                  backgroundColor: Colors.blue.shade300,
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
    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        double animatedValue = _scoreAnimationController.value;
        return Column(
          children: [
            Transform.scale(
              scale: 1.0 + (animatedValue * 0.3),
              child: Text(
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
            ),
            Text(
              'Last Score: $lastScore',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHint() {
    setState(() {
      hintText = 'Hint: There are $correctNumber stars!';
    });
  }

  Widget _buildHint() {
    return GestureDetector(
      onTap: _showHint,
      child: Column(
        children: [
          Tooltip(
            message: 'Hint: Count the stars and select the correct number!',
            child: Icon(
              Icons.lightbulb,
              color: Colors.white70,
              size: 40,
            ),
          ),
          if (hintText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                hintText,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Star Counting Game',
          style: TextStyle(fontFamily: 'OpenDyslexic'),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScore(),
                SizedBox(height: 20),
                _buildHint(),
                SizedBox(height: 30),
                _buildStars(),
                SizedBox(height: 30),
                _buildOptions(),
                SizedBox(height: 20),
                _buildFeedback(),
                _buildCountdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
