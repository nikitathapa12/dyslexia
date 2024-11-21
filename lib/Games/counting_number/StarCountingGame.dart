import 'dart:math';
import 'package:dyslearn/games.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarCountingGame extends StatefulWidget {
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
    _loadLastScore(); // Load the last score from Firebase
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

  // Load the last score from Firebase
  Future<void> _loadLastScore() async {
    try {
      User? parent = FirebaseAuth.instance.currentUser;
      if (parent == null) {
        print("No parent is logged in.");
        return;
      }

      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parent.uid)
          .get();

      if (parentDoc.exists) {
        QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
            .collection('parents')
            .doc(parent.uid)
            .collection('children')
            .get();

        if (childrenSnapshot.docs.isNotEmpty) {
          String childId = childrenSnapshot.docs.first.id;

          DocumentSnapshot gameDataDoc = await FirebaseFirestore.instance
              .collection('parents')
              .doc(parent.uid)
              .collection('children')
              .doc(childId)
              .collection('Star Counting')
              .doc('gameData')
              .get();

          if (gameDataDoc.exists) {
            setState(() {
              lastScore = gameDataDoc['lastScore'] ?? 0;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading last score: $e");
    }
  }

  // Save the score to Firebase
  Future<void> _saveScoreToFirebase() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      DocumentReference parentDoc =
      FirebaseFirestore.instance.collection('parents').doc(parent.uid);

      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();
      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      String childId = childrenSnapshot.docs.first.id;

      CollectionReference gameDataCollection = parentDoc
          .collection('children')
          .doc(childId)
          .collection('Star Counting');

      await gameDataCollection.doc('gameData').set({
        'lastScore': score,
        'totalScore': FieldValue.increment(score),
        'attempts': FieldValue.increment(1),
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      print("Score saved to Firebase successfully!");
    } catch (e) {
      print("Error saving score to Firebase: $e");
    }
  }

  void _generateNewRound() {
    if (roundsPlayed >= 5) {
      _saveScoreToFirebase(); // Save the final score
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamesPage()));
      return;
    }

    setState(() {
      roundsPlayed++; // Increment the rounds played
      lastScore = score; // Update lastScore
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
      _saveScoreToFirebase(); // Save score when correct
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
                child: Text(
                  '$option',
                  style: TextStyle(
                    fontSize: 26,
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

  Widget _buildScore() {
    return Column(
      children: [
        Text(
          'Score: $score',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Last Score: $lastScore',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ],
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
                _buildStars(),
                SizedBox(height: 20),
                _buildOptions(),
                _buildFeedback(),
                Text(
                  countdown,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
