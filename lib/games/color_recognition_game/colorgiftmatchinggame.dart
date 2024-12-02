import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:dyslearn/Games/color_recognition_game/colorMatchingGame.dart';
import 'package:dyslearn/Games/color_recognition_game/game_over_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GiftMatchingPage extends StatefulWidget {
  final String? selectedChildName;


  GiftMatchingPage({this.selectedChildName});

  @override
  _GiftMatchingPageState createState() => _GiftMatchingPageState();
}

class _GiftMatchingPageState extends State<GiftMatchingPage> with SingleTickerProviderStateMixin {
  List<String> giftImages = [
    'assets/images/gift_red.png', 'assets/images/gift_red.png',
    'assets/images/gift_green.png', 'assets/images/gift_green.png',
    'assets/images/gift_blue.png', 'assets/images/gift_blue.png',
    'assets/images/gift_purple.png', 'assets/images/gift_purple.png',
    'assets/images/gift_orange.png', 'assets/images/gift_orange.png',
    'assets/images/gift_yellow.png', 'assets/images/gift_yellow.png',
  ];

  List<bool> matched = List.generate(12, (index) => false);
  late ConfettiController _confettiController;
  String? selectedGiftImage;
  int? selectedIndex;
  int score = 0;

  int lastScore = 0; // New field for last score
  int attempts = 0;
  late AudioPlayer _audioPlayer;
  bool isHintActive = false;
  late SharedPreferences prefs;
  late FlutterTts flutterTts;
  bool _isConfettiPlaying = false; // Track confetti animation state

  List<bool> opening = List.generate(12, (index) => false);
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    flutterTts = FlutterTts();
    giftImages.shuffle();
    _playBackgroundMusic();

    _initializePreferences();
    fetchLastScore();
  }

  void _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('lastScore') ?? 0; // Fetch last score or default to 0
    });
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
            .collection('Gift Matching')
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
            .collection('Gift Matching')
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

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }


  void _playBackgroundMusic() async {
    try {
      await _audioPlayer.setSource(AssetSource('assets/audio/background_music.mp3'));
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.resume();
    } catch (e) {
      print("Error playing background music: $e");
    }
  }
  bool _isAllMatched() {
    return matched.every((element) => element == true);
  }

  void _onGiftTap(int index) {
    if (matched[index] || isHintActive) return;

    if (selectedGiftImage == null) {
      setState(() {
        selectedGiftImage = giftImages[index];
        selectedIndex = index;
      });
      _speakGift(giftImages[index]);
    } else {
      if (giftImages[index] == selectedGiftImage && selectedIndex != index) {
        _playSound('assets/audio/correct.mp3');
        setState(() {
          matched[index] = true;
          matched[selectedIndex!] = true;
          opening[selectedIndex!] = true;
          opening[index] = true;
          selectedGiftImage = null;
          selectedIndex = null;
          score += 1;
        });

        // Manage confetti animation state
        if (!_isConfettiPlaying) {
          _confettiController.play();
          _isConfettiPlaying = true;

          // Automatically stop confetti after its duration
          Future.delayed(Duration(seconds: 2), () {
            _confettiController.stop();
            _isConfettiPlaying = false;
          });
        }

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            opening[selectedIndex!] = false;
            opening[index] = false;
          });
        });
      } else {
        _playSound('assets/audio/incorrect.mp3');
        setState(() {
          selectedGiftImage = null;
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
    if (isHintActive) return;

    setState(() {
      isHintActive = true;
    });

    for (int i = 0; i < giftImages.length; i++) {
      for (int j = i + 1; j < giftImages.length; j++) {
        if (giftImages[i] == giftImages[j] && !matched[i] && !matched[j]) {
          setState(() {
            opening[i] = true;
            opening[j] = true;
          });

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              opening[i] = false;
              opening[j] = false;
              isHintActive = false;
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
      score = 0; // Reset the score to 0
      matched = List.generate(12, (index) => false);
      opening = List.generate(12, (index) => false);
      giftImages.shuffle();
    });
    Navigator.pop(context);
  }


  void _initializePreference() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('lastScore') ?? 0; // Fetch last score or default to 0
    });
  }


  void _goToNextGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorMatchingGame(
          selectedChildName: widget.selectedChildName,
        ),
      ),
    );
  }

  void _speakGift(String giftImage) async {
    String giftName = '';
    if (giftImage.contains('red')) giftName = 'Red';
    if (giftImage.contains('green')) giftName = 'Green';
    if (giftImage.contains('blue')) giftName = 'Blue';
    if (giftImage.contains('purple')) giftName = 'Purple';
    if (giftImage.contains('orange')) giftName = 'Orange';
    if (giftImage.contains('yellow')) giftName = 'Yellow';

    await flutterTts.speak(giftName);
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.lightbulb, color: Colors.orange, size: 32),
                      onPressed: isHintActive ? null : _useHint,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.greenAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 4, blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Score: $score  ',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Last: ${prefs.getInt('lastScore') ?? 0}',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(), // Pushes content to center vertically
              // Gift grid view
              Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: giftImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onGiftTap(index),
                      child: AnimatedOpacity(
                        opacity: matched[index] ? 0.2 : 1,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(giftImages[index]),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Spacer(), // Add spacing below the grid
              ElevatedButton(
                onPressed: _useHint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Use Hint",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Spacer(), // Balances spacing at the bottom
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
          ),
        ],
      ),
    );
  }


}
