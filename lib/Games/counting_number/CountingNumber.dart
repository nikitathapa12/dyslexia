import 'dart:math';
import 'package:dyslearn/Games/counting_number/StarCountingGame.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CountingGame extends StatefulWidget {
  @override
  _CountingGameState createState() => _CountingGameState();
}

class _CountingGameState extends State<CountingGame> with TickerProviderStateMixin {
  int correctNumber = 0;
  int score = 0;
  int lastScore = 0;
  int roundsPlayed = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String countdown = '';
  String hintText = 'Listen carefully to the sound and count the candles!';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _generateNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Generate a new round
  void _generateNewRound() {
    setState(() {
      correctNumber = Random().nextInt(9) + 1; // Random number between 1 and 9
      _isAnswered = false;
      _isCorrect = false;
      countdown = '';
      hintText = 'Listen carefully to the sound and count the candles!';
    });
    _playNumberSound(correctNumber); // Play the sound of the number
  }

  // Play number sound
  void _playNumberSound(int number) async {
    await _audioPlayer.play(AssetSource('audio/$number.mp3'));
  }

  // Play feedback sound
  void _playFeedbackSound(bool isCorrect) async {
    String soundPath = isCorrect ? 'assets/audio/correct.mp3' : 'assets/audio/incorrect.mp3';
    await _audioPlayer.play(AssetSource(soundPath));
  }

  // Handle option selection
  void _handleOptionSelected(int selectedNumber) {
    if (selectedNumber == correctNumber) {
      setState(() {
        _isAnswered = true;
        _isCorrect = true;
        lastScore = score;
        score++;
        roundsPlayed++;
      });
      _playFeedbackSound(true);
      _startCountdown();
    } else {
      setState(() {
        _isAnswered = true;
        _isCorrect = false;
        lastScore = score;
        roundsPlayed++;
      });
      _playFeedbackSound(false);
      _generateNewRound();
    }

    // After 2 rounds, navigate to the next page
    if (roundsPlayed >= 2) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StarCountingGame()),
        );
      });
    }
  }

  // Start countdown after correct answer
  void _startCountdown() async {
    for (int i = 1; i <= correctNumber; i++) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        countdown += '$i ';
      });
    }
    await Future.delayed(Duration(seconds: 1));
    _generateNewRound();
  }

  // Build the cake with candles
  Widget _buildCakeWithCandles() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/cake.png', height: 300, width: 400),
            for (int i = 0; i < correctNumber; i++)
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: 20,
                left: correctNumber == 1
                    ? 140
                    : 140 + (i * (50 / (correctNumber - 1))),
                child: Image.asset(
                  'assets/images/candle.gif',
                  height: 50,
                  width: 30,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Build the options for the user to select
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
          'How many candles are there on the cake?',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'OpenDyslexic',
            letterSpacing: 2,
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
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  '$option',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Build feedback
  Widget _buildFeedback() {
    if (_isAnswered) {
      return _isCorrect
          ? Text(
        'Correct!',
        style: TextStyle(
          color: Colors.green,
          fontSize: 24,
          fontFamily: 'OpenDyslexic',
        ),
      )
          : Text(
        'Wrong! Try again.',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontFamily: 'OpenDyslexic',
        ),
      );
    }
    return Container();
  }

  // Build countdown
  Widget _buildCountdown() {
    return Text(
      countdown,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        fontFamily: 'OpenDyslexic',
      ),
    );
  }

  // Build the score, last score, and hint at the top
  Widget _buildTopInfo() {
    return Column(
      children: [
        Text(
          'Score: $score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenDyslexic',
          ),
        ),
        Text(
          'Last Score: $lastScore',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenDyslexic',
          ),
        ),
        Text(
          hintText,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontFamily: 'OpenDyslexic',
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counting Game', style: TextStyle(fontFamily: 'OpenDyslexic')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopInfo(),
            SizedBox(height: 20),
            _buildCakeWithCandles(),
            SizedBox(height: 40),
            _buildOptions(),
            SizedBox(height: 20),
            _buildFeedback(),
            _buildCountdown(),
          ],
        ),
      ),
    );
  }
}
