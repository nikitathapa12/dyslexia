import 'dart:math';
import 'package:dyslearn/games.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarCountingGame extends StatefulWidget {
  final String? selectedChildName;

  StarCountingGame({this.selectedChildName});

  @override
  _StarCountingGameState createState() => _StarCountingGameState();
}

class _StarCountingGameState extends State<StarCountingGame> with TickerProviderStateMixin {
  int correctNumber = 0;
  int score = 0;
  int lastScore = 0;
  int roundsPlayed = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String countdown = '';
  List<AnimationController> _bounceControllers = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _scoreAnimationController;
  late FirebaseFirestore firestore;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    showHint = false;
    firestore = FirebaseFirestore.instance;
    fetchLastScore(); // Fetch the last saved score
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _generateNewRound();
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

  Future<void> fetchLastScore() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) return;

    try {
      final childDocs = await firestore
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)
          .get();

      if (childDocs.docs.isNotEmpty) {
        String childId = childDocs.docs.first.id;

        final gameDoc = await firestore
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(childId)
            .collection('Star Counting')
            .doc('gameData')
            .get();

        if (gameDoc.exists) {
          setState(() {
            lastScore = gameDoc['lastScore'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error fetching last score: $e");
    }
  }

  // Save the current score to Firestore
  Future<void> saveScoreToFirebase() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) return;

    try {
      final childDocs = await firestore
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)
          .get();

      if (childDocs.docs.isNotEmpty) {
        String childId = childDocs.docs.first.id;

        DocumentReference gameDoc = firestore
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .doc(childId)
            .collection('Star Counting')
            .doc('gameData');

        await gameDoc.set({
          'lastScore': score,
          'totalScore': FieldValue.increment(score),
          'attempts': FieldValue.increment(1),
          'lastUpdated': Timestamp.now(),
        }, SetOptions(merge: true));

        print("Score saved successfully!");
      }
    } catch (e) {
      print("Error saving score: $e");
    }
  }


  void _generateNewRound() {
    if (roundsPlayed >= 5) {
      saveScoreToFirebase();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamesPage(selectedChildName: widget.selectedChildName)));
      return;
    }

    setState(() {
      roundsPlayed++;
      correctNumber = Random().nextInt(9) + 1;
      _isAnswered = false;
      _isCorrect = false;
      countdown = '';
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
      await _playCorrectSound(); // Play correct sound
      saveScoreToFirebase();
      _startCountdown();
    } else {
      setState(() {
        _isAnswered = true;
        _isCorrect = false;
      });
      await _playIncorrectSound(); // Play incorrect sound
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
    List<int> options = [correctNumber];
    while (options.length < 4) {
      int randomOption = Random().nextInt(9) + 1;
      if (!options.contains(randomOption)) options.add(randomOption);
    }
    options.shuffle();

    return Column(
      children: [
        Text(
          'How many stars are there?',
          style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', fontWeight: FontWeight.bold, color: Colors.white),
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
                child: Text(
                  '$option',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'OpenDyslexic',
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }


  Widget _buildScore() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'OpenDyslexic',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {

                  showHint = !showHint;
                });
              },
              child: Icon(
                Icons.lightbulb,
                color: Colors.yellow,
                size: 24,
              ),
            ),
          ],
        ),
        if (showHint)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hint: Count the stars one by one carefully. Match the number of stars with the correct option.',
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          'Last Score: $lastScore',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'OpenDyslexic',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.lightBlue.shade300]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScore(),
              SizedBox(height: 20),
              _buildStars(),
              SizedBox(height: 20),
              _buildOptions(),
              if (_isAnswered) Text(_isCorrect ? 'Correct!' : 'Wrong! Try again.', style: TextStyle(fontSize: 30)),
              SizedBox(height: 10),
              Text(countdown, style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
