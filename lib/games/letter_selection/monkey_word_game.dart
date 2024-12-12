
import 'package:dyslearn/games.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonkeyWordGame extends StatefulWidget {
  final String? selectedChildName;

  MonkeyWordGame({this.selectedChildName});
  @override
  _MonkeyWordGameState createState() => _MonkeyWordGameState();
}

class _MonkeyWordGameState extends State<MonkeyWordGame> with SingleTickerProviderStateMixin {
  final String word = "MONKEY";
  List<String> letters = ['Y', 'N', 'E', 'M', 'O', 'K'];
  late List<String?> filledLetters;
  late AnimationController _controller;

  late FirebaseFirestore firestore; // Firestore instance

  bool _isCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  int score = 0;
  int lastScore = 0;

  @override
  void initState() {
    super.initState();
    filledLetters = List.generate(word.length, (index) => null);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    firestore = FirebaseFirestore.instance;
    _playBackgroundMusic(); // Start background music
    fetchLastScore(); // Fetch last score from Firebase
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _backgroundMusicPlayer.stop(); // top background music
    _stopMusic();
    _backgroundMusicPlayer.dispose(); // Dispose background music player
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
            .collection('Monkey Word Selection')
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
            .collection('Monkey Word Selection')
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

  // Play background music
  Future<void> _playBackgroundMusic() async {
    await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'), volume: 0.5);
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop); // Loop the background music
  }

  // Play letter sound (phonics) or word sound
  Future<void> _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('audio/$soundFile.mp3'));
  }



  // function to stop the background music
  Future<void> _stopMusic() async {
    await _backgroundMusicPlayer.stop();
  }




  // Handle the letter tap event
  void _onLetterTapped(String letter) {
    for (int i = 0; i < word.length; i++) {
      if (filledLetters[i] == null && word[i] == letter) {
        setState(() {
          filledLetters[i] = letter; // Fill the letter in the word
          letters.remove(letter); // Remove the letter from the pool
          score += 1;

          // Play phonics sound for the tapped letter
          _playSound(letter.toLowerCase());

          if (_isWordCompleted()) {
            _isCompleted = true;
            _controller.forward();

            saveScoreToFirebase(); // Save score to Firestore

            // Stop the background music when the game is completed
            _stopMusic();

            // Wait for the last phonics sound to finish before playing "monkey"
            Future.delayed(Duration(seconds: 1), () {
              _playSound('monkey');

              // Update scores
              setState(() {
                lastScore = score;
                score = 0;
              });

              // After playing sound, navigate to the next word task
              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GamesPage(selectedChildName: "",)));
              });
            });
          }
        });
        break;
      }
    }
  }

  // Check if the word is completed
  bool _isWordCompleted() {
    return !filledLetters.contains(null);
  }

  // Use hint functionality: Automatically place one correct letter
  void _useHint() {
    for (int i = 0; i < word.length; i++) {
      if (filledLetters[i] == null) {
        String correctLetter = word[i];
        if (letters.contains(correctLetter)) {
          _onLetterTapped(correctLetter); // Tap the correct letter
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/monkey-7751_512.gif"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Scoreboard and hint row
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Last Score: $lastScore',
                        style: TextStyle(fontSize: 14,fontFamily: 'OpenDyslexic', color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.lightbulb, color: Colors.yellow),
                    onPressed: _useHint,
                  ),
                ],
              ),
            ),
          ),
          // Main game content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(word.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: filledLetters[index] != null ? Colors.lightGreen : Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          filledLetters[index] ?? word[index],
                          style: TextStyle(fontSize: 14, fontFamily: 'OpenDyslexic'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: letters.map((letter) {
                  return GestureDetector(
                    onTap: () => _onLetterTapped(letter),
                    child: _buildLetterWidget(letter),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              if (_isCompleted) _buildWavingIcons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterWidget(String letter) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWavingIcons() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159,
          child: Icon(Icons.cached, color: Colors.blue, size: 50),
        );
      },
    );
  }
}
