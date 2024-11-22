import 'dart:math';
import 'package:dyslearn/Games/counting_number/StarCountingGame.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CherryCountingGame extends StatefulWidget {
  final String? selectedChildName;

  CherryCountingGame({this.selectedChildName});

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
  bool _hintUsed = false;
  String countdown = '';
  List<AnimationController> _bounceControllers = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _scoreAnimationController;
  late FirebaseFirestore firestore; // Firestore instance


  @override
  void initState() {
    super.initState();
    _generateNewRound();
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    firestore = FirebaseFirestore.instance;


    fetchLastScore();  // Load the last score on game start
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

  // Load the last score from Firestore
  // Load the last score from Firestore
  Future<void> fetchLastScore() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) return; // No user logged in

    try {
      DocumentSnapshot doc = await firestore
          .collection('parents')
          .doc(parent.uid)

          .collection('Cherry Counting')
          .doc('GameData')
          .get();

      if (doc.exists) {
        setState(() {
          lastScore = doc['lastScore'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching last score: $e");
    }
  }

  // Save the current score to Firestore
  Future<void> saveScoreToFirebase() async {
    // Get the currently logged-in parent's ID
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      // Access the parent's document
      DocumentReference parentDoc = firestore.collection('parents').doc(parent.uid);

      // Retrieve the first child document in the 'children' subcollection
      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();
      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      // Assuming you want to use the first child (or modify as needed)
      print("child name: ");
      print(widget.selectedChildName);

      final childDocs = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parent.uid)
          .collection('children')
          .where('name', isEqualTo: widget.selectedChildName)  // Use the selected child's name
          .get();

      String childId = childDocs.docs.first.id; // Extract the childId
      print("retrieved child id: $childId");


      // Reference to the gameData subcollection under the child's document
      CollectionReference gameDataCollection = parentDoc.collection('children').doc(childId).collection('Cherry Counting');

      Map<String, dynamic> gameData = {
        'lastScore': score,
        'totalScore': FieldValue.increment(score),
        'attempts': FieldValue.increment(1),
        'lastUpdated': Timestamp.now(),
      };

      await gameDataCollection.add(gameData);
      print("Score saved to Firebase successfully!");
    } catch (e) {
      print("Error saving score to Firebase: $e");
    }
  }

  void _generateNewRound() {
    setState(() {
      lastScore = score;
      correctNumber = Random().nextInt(9) + 1;
      _isAnswered = false;
      _isCorrect = false;
      countdown = '';
      _showHint = false;
      _hintUsed = false;
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

  void _checkGameCompletion() async {
    roundsPlayed++;
    if (roundsPlayed >= 2) {
      saveScoreToFirebase();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StarCountingGame(selectedChildName: widget.selectedChildName,)),
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
                    'Score',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Last Score: $lastScore',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHintIcon() {
    return GestureDetector(
      onTap: _showHintMessage,
      child: Icon(
        Icons.lightbulb,
        color: _showHint ? Colors.yellow : Colors.yellow,
        size: 35,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Display Score and Last Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: $score',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Last Score: $lastScore',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ],
            ),
            // Hint Icon
            _buildHintIcon(),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCherries(),
            SizedBox(height: 20),
            _buildOptions(),
            _buildFeedback(),
            _buildCountdown(),
          ],
        ),
      ),
    );
  }

}
