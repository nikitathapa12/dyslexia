import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'ColorGiftMatchingGame.dart';
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
    final doc = await firestore.collection('games').doc('Game Recognition').get();
    if (doc.exists) {
      setState(() {
        lastScore = doc['lastScore'] ?? 0;  // Use a default value if lastScore doesn't exist
      });
    }
  }

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
      CollectionReference gameDataCollection = parentDoc.collection('children').doc(childId).collection('Game Recognition');
      print("childId: $childId");
      // Prepare game data to store in Firestore
      Map<String, dynamic> gameData = {
        'lastScore': score,  // Current score
        'totalScore': FieldValue.increment(score),  // Increment total score by the current score
        'attempts': FieldValue.increment(1),  // Increment attempts by 1
        'lastUpdated': Timestamp.now(),
      };
      print("sent data: ");
      print(gameData.entries);
      // Add or update game data document in the 'gameData' subcollection
      await gameDataCollection.add(gameData);

      print("Score saved to Firebase successfully!");
    } catch (e) {
      print("Error saving score to Firebase: $e");
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
      setState(() async {
        attempts++;
        if (attempts >= 3) {
          isGameOver = true;

          // Dynamically retrieve and save the score
          await saveScoreToFirebase();

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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
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
                                  fontSize: 40,
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
                              style: TextStyle(color: Colors.white, fontSize: 16),
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