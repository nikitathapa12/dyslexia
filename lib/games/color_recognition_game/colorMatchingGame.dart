import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:dyslearn/games.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'draggable_bag.dart';
import 'kid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ColorMatchingGame extends StatefulWidget {
  final String? selectedChildName;

  ColorMatchingGame({this.selectedChildName});

  @override
  _ColorMatchingGameState createState() => _ColorMatchingGameState();
}

class _ColorMatchingGameState extends State<ColorMatchingGame>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  List<bool> _kidHasBag = [false, false, false, false];
  List<String?> _matchedBagImage = [null, null, null, null];

  List<String> goodyBagImages = [
    'assets/images/bag_green.jpg',
    'assets/images/bag_blue.jpg',
    'assets/images/bag_red.png',
    'assets/images/bag_yellow.png',
  ];

  List<String> kidImages = [
    'assets/images/kid1.png',
    'assets/images/kid2.png',
    'assets/images/kid3.jpg',
    'assets/images/kid4.jpg',
  ];

  final List<Color> bagColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.yellow,
  ];

  final List<Color> kidColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.yellow,
  ];

  int score = 0;
  int lastScore = 0;
  bool _showHint = false;


  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _flutterTts.setLanguage("en-US");
    _flutterTts.speak(
        "Welcome to the Color Matching Game! Match each kid with the correct color bag.");
    fetchLastScore(); // Fetch the last score when the game starts

  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Fetch the last score from Firebase
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
            .collection('Color Matching')
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

  // Save the current score to Firebase
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
            .collection('Color Matching')
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




  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$sound'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _vibrateFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }


  //called when a bag is dragged tp a kid
  void _onMatch(Color bagColor, Color kidColor, int kidIndex) {
    if (bagColor == kidColor) {
      _playSound('correct.mp3');
      _confettiController.play();
      _speakText("Yay! Right color, you did it!");
      _vibrateFeedback();
      setState(() {
        _kidHasBag[kidIndex] = true;
        _matchedBagImage[kidIndex] = goodyBagImages[kidIndex];
        score += 1;
      });

      // Check if all matches are complete
      if (!_kidHasBag.contains(false)) {
        saveScoreToFirebase(); // Save the score before navigating

        // Navigate to the GamesPage
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GamesPage()),
          );
        });
      }
    } else {
      _playSound('incorrect.mp3');
      _speakText("Oops! Try again, that doesn't match!");
      _vibrateFeedback();
    }
  }


  void _showHintMessage() {
    setState(() {
      _showHint = true;
    });
    _speakText("Hint: Match colors carefully!");

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showHint = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Color Matching Game", )),
      body: Stack(
        children: [
          Column(
            children: [
              _buildScoreBoard(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildKidsColumn(),
                    SizedBox(width: 40),
                    _buildReversedGoodyBagsColumn(),
                  ],
                ),
              ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: [Colors.green, Colors.blue, Colors.pink, Colors.purple],
            shouldLoop: false,
          ),
          if (_showHint)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  'Hint: Drag the same color shopping bag to the kids',
                  style: TextStyle(
                    fontFamily:'OpenDyslexic',fontSize: 14,

                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(fontFamily:'OpenDyslexic',fontSize: 14),
                    ),
                    Text(
                      'Last Score: $lastScore',
                      style: TextStyle(fontFamily:'OpenDyslexic',fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.lightbulb_sharp, color: Colors.yellow, size: 30),
            onPressed: _showHintMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildReversedGoodyBagsColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(goodyBagImages.length, (index) {
        return Align(
          alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14),
              child: DraggableGoodyBag(
                color: bagColors[index],
                child: Image.asset(goodyBagImages[index], width: 100, height: 100),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKidsColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(kidImages.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Kid(
            color: kidColors[index],
            onMatched: (bagColor, kidColor) => _onMatch(bagColor, kidColor, index),
            child: Image.asset(kidImages[index], width: 100, height: 100),
            hasMatchedBag: _kidHasBag[index],
            matchedBagImage: _matchedBagImage[index],
          ),
        );
      }),
    );
  }
}
