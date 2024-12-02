import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'colorgiftmatchinggame.dart';
import 'game_over_page.dart';

class ColorRecognitionGame extends StatefulWidget {
  final String? selectedChildName;

  ColorRecognitionGame({this.selectedChildName});
  @override
  _ColorRecognitionGameState createState() => _ColorRecognitionGameState();
}

class _ColorRecognitionGameState extends State<ColorRecognitionGame>
    with TickerProviderStateMixin {
  final List<Color> fruitColors = [
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.black,
    Colors.purple.shade700,
    Colors.pink.shade200,
  ];

  final List<String> fruitImages = [
    'assets/images/apple.png',
    'assets/images/banana.png',
    'assets/images/blueberry.png',
    'assets/images/watermelon.png',
    'assets/images/mango_orange.png',
    'assets/images/black.png',
    'assets/images/grapes.png',
    'assets/images/peach.png',
  ];

  final List<String> colorSounds = [
    'audio/red.mp3',
    'audio/yellow.mp3',
    'audio/blue.mp3',
    'audio/green.mp3',
    'audio/orange.mp3',
    'audio/black.mp3',
    'audio/purple.mp3',
    'audio/pink.mp3',
  ];

  final List<String> colorNames = [
    'Red',
    'Yellow',
    'Blue',
    'Green',
    'Orange',
    'Black',
    'Purple',
    'Pink',
  ];

  String selectedFruitImage = '';
  Color selectedFruitColor = Colors.red;
  int score = 0;
  int lastScore = 0; // New field for last score
  int attempts = 0;
  bool isGameOver = false;
  bool showHint = false;
  bool showPlusOne = false;

  late AudioPlayer audioPlayer;
  late FlutterTts flutterTts;
  late FirebaseFirestore firestore; // Firestore instance

  late AnimationController _controller;
  late Animation<double> _fruitAnimation;
  late AnimationController _plusOneController;
  late Animation<double> _plusOneAnimation;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    flutterTts = FlutterTts();
    firestore = FirebaseFirestore.instance;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fruitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _plusOneController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _plusOneAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(parent: _plusOneController, curve: Curves.easeOut),
    );

    _speak(
        "Welcome to the Color Recognition Game. Tap on the color of the fruit shown.");
    fetchLastScore(); // Fetch last score from Firebase
    generateRandomFruit();
  }

  // Add a parameter for gameId to differentiate between games
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
            .collection('Game Recognition')
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
            .collection('Game Recognition')
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




  void generateRandomFruit() {
    final random = Random();
    int fruitIndex = random.nextInt(fruitImages.length);
    selectedFruitImage = fruitImages[fruitIndex];
    selectedFruitColor = fruitColors[fruitIndex];
    _controller.forward(from: 0.0);
    showHint = false;
    setState(() {});
  }

  Future<void> checkColor(Color selectedColor, int colorIndex) async {
    if (isGameOver) return;

    if (selectedColor == selectedFruitColor) {
      await _playSound(colorSounds[colorIndex]);
      await _speak(colorNames[colorIndex]);

      setState(() {
        showPlusOne = true;
        _plusOneController.forward(from: 0.0);
        score++;
        attempts = 0;
        generateRandomFruit();
      });
    } else {
      await _playSound('audio/incorrect.mp3');
      await _speak('Oops, try again.');
      setState(() {
        attempts++;
        if (attempts >= 2) {  // End the game after 7 attempts
          isGameOver = true;

          // Save the score to Firebase and navigate to the GameOverScreen
          saveScoreToFirebase();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameOverScreen(
                score: score,
                onPlayAgain: _resetGame,
                onNextGame: _goToNextGame,
              ),
            ),
          );
        }
      });
    }
  }




Future<void> _playSound(String soundFile) async {
    try {
      await audioPlayer.setSource(AssetSource(soundFile));
      await audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _resetGame() {
    setState(() {
      score = 0;
      attempts = 0;
      isGameOver = false;
      fetchLastScore();
      generateRandomFruit();
    });
    Navigator.pop(context);
  }

  void _goToNextGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftMatchingPage(selectedChildName: widget.selectedChildName,),
      ),
    );
  }

  void giveHint() async {
    await _speak(
        'The correct color is ${colorNames[fruitColors.indexOf(selectedFruitColor)]}');
    setState(() {
      showHint = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _plusOneController.dispose();
    audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/jungle.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score Display in a Card
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Last Score: $lastScore',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenDyslexic',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenDyslexic',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _fruitAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fruitAnimation.value,
                          child: Transform.scale(
                            scale: _fruitAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        selectedFruitImage,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    if (showPlusOne)
                      AnimatedBuilder(
                        animation: _plusOneAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _plusOneAnimation.value + 100,
                            left: 100,
                            child: Opacity(
                              opacity: 1 - (_plusOneAnimation.value / -50),
                              child: Text(
                                '+1',
                                style: TextStyle(
                                  fontFamily: 'OpenDyslexic',
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 20),
                IconButton(
                  icon: Icon(Icons.lightbulb, color: Colors.yellow, size: 40),
                  onPressed: giveHint,
                  tooltip: 'Hint',
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: fruitColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => checkColor(fruitColors[index], index),
                        child: Container(
                          color: fruitColors[index],
                          child: Center(
                            child: Text(
                              colorNames[index],
                              style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'OpenDyslexic'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}