import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
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
  bool isHintActive = false; // Updated flag for active hint
  late SharedPreferences prefs;

  List<bool> opening = List.generate(12, (index) => false);
  late FlutterTts flutterTts; // TTS instance

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    flutterTts = FlutterTts(); // Initialize TTS
    giftColors.shuffle();
    _playBackgroundMusic();
    _initializePreferences();
  }

  void _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    score = prefs.getInt('lastScore') ?? 0;
    setState(() {});
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop(); // Stop TTS when disposing
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
                    child: Column(
                      children: [
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Last Score: ${widget.lastScore ?? 0}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.lightbulb_sharp, color: Colors.yellow, size: 40),
              onPressed: _useHint,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGiftGrid(),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.yellow,
            ],
            shouldLoop: false,
            numberOfParticles: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildGiftGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: giftColors.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onGiftTap(index),
          child: AnimatedScale(
            scale: matched[index] ? 0.8 : 1.0,
            duration: Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: opening[index] ? 0.0 : 1.0,
              duration: Duration(milliseconds: 1200),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 1200),
                decoration: BoxDecoration(
                  color: matched[index] ? Colors.transparent : giftColors[index],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: matched[index]
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: matched[index]
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _getGiftImage(giftColors[index]),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    Text('🎁', style: TextStyle(fontSize: 34)),
                  ],
                )
                    : Center(child: Text('🎁', style: TextStyle(fontSize: 25))),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGiftImage(Color color) {
    if (color == Colors.red) return 'assets/images/red_gift.png';
    if (color == Colors.green) return 'assets/images/green_gift.png';
    if (color == Colors.blue) return 'assets/images/blue_gift.png';
    if (color == Colors.purple) return 'assets/images/purple_gift.png';
    if (color == Colors.orange) return 'assets/images/orange_gift.png';
    if (color == Colors.yellow) return 'assets/images/yellow_gift.png';
    return '';
  }
}
