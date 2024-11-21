import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:dyslearn/Games/color_recognition_game/ColorMatchingGame.dart';
import 'package:dyslearn/Games/color_recognition_game/game_over_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GiftMatchingPage extends StatefulWidget {
  final int? lastScore;

  GiftMatchingPage({this.lastScore});

  @override
  _GiftMatchingPageState createState() => _GiftMatchingPageState();
}

class _GiftMatchingPageState extends State<GiftMatchingPage>
    with SingleTickerProviderStateMixin {
  List<Color> giftColors = [
    Colors.red,
    Colors.red,
    Colors.green,
    Colors.green,
    Colors.blue,
    Colors.blue,
    Colors.purple,
    Colors.purple,
    Colors.orange,
    Colors.orange,
    Colors.yellow,
    Colors.yellow,
  ];

  List<bool> matched = List.generate(12, (index) => false);
  late ConfettiController _confettiController;
  Color? selectedColor;
  int? selectedIndex;
  int score = 0;
  late AudioPlayer _audioPlayer;
  bool isHintActive = false;
  late SharedPreferences prefs;
  late FlutterTts flutterTts;

  List<bool> opening = List.generate(12, (index) => false);
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    flutterTts = FlutterTts(); // Initialize TTS
    giftColors.shuffle();

    _initializePreferences();
    fetchLastScore();  // Fetch the last score from Firestore when the game starts
  }

  void _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    score = 0; // Reset score on start
    prefs.setInt('lastScore', score);
    setState(() {});
  }

  Future<void> fetchLastScore() async {
    final doc = await firestore.collection('games').doc('Gift Matching').get();
    if (doc.exists) {
      setState(() {
        score = doc['lastScore'] ?? 0;  // Use a default value if lastScore doesn't exist
      });
    }
  }

  Future<void> saveScoreToFirebase() async {
    User? parent = FirebaseAuth.instance.currentUser;
    if (parent == null) {
      print("No parent is logged in.");
      return;
    }

    try {
      DocumentReference parentDoc = firestore.collection('parents').doc(parent.uid);
      QuerySnapshot childrenSnapshot = await parentDoc.collection('children').get();
      if (childrenSnapshot.docs.isEmpty) {
        print("No children found for this parent.");
        return;
      }

      DocumentSnapshot childDoc = childrenSnapshot.docs.first;
      String childId = childDoc.id;

      CollectionReference gameDataCollection = parentDoc.collection('children').doc(childId).collection('Gift Matching');
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

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop(); // Stop TTS when disposing
    super.dispose();
  }

  bool _isAllMatched() {
    return matched.every((element) => element == true);
  }

  void _onGiftTap(int index) {
    if (matched[index] || isHintActive) return; // Disable tap if hint is active

    if (selectedColor == null) {
      setState(() {
        selectedColor = giftColors[index];
        selectedIndex = index;
      });
      _speakColor(giftColors[index]); // Announce the color when tapped
    } else {
      if (giftColors[index] == selectedColor && selectedIndex != index) {
        _playSound('assets/audio/correct.mp3');
        setState(() {
          matched[index] = true;
          matched[selectedIndex!] = true;
          opening[selectedIndex!] = true;
          opening[index] = true;
          selectedColor = null;
          selectedIndex = null;
          score += 1;
        });
        _confettiController.play();

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            opening[selectedIndex!] = false;
            opening[index] = false;
          });
        });
      } else {
        _playSound('assets/audio/incorrect.mp3');
        setState(() {
          selectedColor = null;
          selectedIndex = null;
        });
      }
    }

    if (_isAllMatched()) {
      prefs.setInt('lastScore', score);
      saveScoreToFirebase();
      _navigateToGameOverScreen();
    }
  }

  void _playSound(String path) async {
    try {
      await _audioPlayer.setSource(AssetSource(path));
      await _audioPlayer.resume();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _useHint() {
    if (isHintActive) return; // Prevent multiple hints at once
    setState(() {
      isHintActive = true;
    });

    for (int i = 0; i < giftColors.length; i++) {
      for (int j = i + 1; j < giftColors.length; j++) {
        if (giftColors[i] == giftColors[j] && !matched[i] && !matched[j]) {
          setState(() {
            opening[i] = true;
            opening[j] = true;
          });

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              opening[i] = false;
              opening[j] = false;
              isHintActive = false; // Reset hint flag after animation
            });
          });
          return;
        }
      }
    }
  }

  void _navigateToGameOverScreen() {
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

  void _resetGame() {
    setState(() {
      score = 0;
      matched = List.generate(12, (index) => false);
      opening = List.generate(12, (index) => false);
      giftColors.shuffle();
    });
    Navigator.pop(context);
  }

  void _goToNextGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorMatchingGame(),
      ),
    );
  }

  void _speakColor(Color color) async {
    String colorName = '';
    if (color == Colors.red) colorName = 'Red';
    if (color == Colors.green) colorName = 'Green';
    if (color == Colors.blue) colorName = 'Blue';
    if (color == Colors.purple) colorName = 'Purple';
    if (color == Colors.orange) colorName = 'Orange';
    if (color == Colors.yellow) colorName = 'Yellow';

    await flutterTts.speak(colorName); // Speak the color name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bbg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Last Score: ${widget.lastScore ?? 0}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.lightbulb_outline, color: Colors.yellow),
                    onPressed: _useHint,
                  ),
                  GridView.builder(
                    padding: EdgeInsets.all(12),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: giftColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onGiftTap(index),
                        child: AnimatedScale(
                          scale: opening[index] ? 1.1 : 1.0,
                          duration: Duration(milliseconds: 200),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: matched[index] ? Colors.transparent : giftColors[index],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              if (!matched[index])
                                Text(
                                  '🎁',
                                  style: TextStyle(fontSize: 32, color: Colors.white),
                                ), // Gift icon
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
