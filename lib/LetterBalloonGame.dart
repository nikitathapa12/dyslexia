import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const LetterBalloonGame());
}

class LetterBalloonGame extends StatefulWidget {
  const LetterBalloonGame({Key? key}) : super(key: key);

  @override
  _LetterBalloonGameState createState() => _LetterBalloonGameState();
}

class _LetterBalloonGameState extends State<LetterBalloonGame> with TickerProviderStateMixin {
  final List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final List<String> letterSounds = [
    'audio/a.mp3',
    'audio/b.mp3',
    'audio/c.mp3',
    'audio/d.mp3',
    'audio/e.mp3',
    'audio/f.mp3',
    'audio/g.mp3',
    'audio/h.mp3',
  ];

  String selectedLetter = '';
  List<String> letterOptions = [];
  int score = 0;
  int attempts = 0;
  bool isGameOver = false;

  late AudioPlayer audioPlayer;
  late FlutterTts flutterTts;
  late ConfettiController _confettiController;
  List<AnimationController> balloonControllers = [];

  late AnimationController backgroundController; // Declare here
  Animation<double>? starAnimation;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    flutterTts = FlutterTts();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    // Initialize the backgroundController
    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    // Initialize starAnimation
    _initializeStarAnimation();

    generateRandomLetterOptions();
    _createBalloonAnimations();
    _playBackgroundMusic();
  }

  void _initializeStarAnimation() {
    starAnimation = Tween<double>(begin: 0, end: 1).animate(backgroundController);
  }

  void _playBackgroundMusic() async {
    try {
      await audioPlayer.setSource(AssetSource('audio/background_music.mp3'));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.resume();
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  void _createBalloonAnimations() {
    for (int i = 0; i < 4; i++) {
      balloonControllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(seconds: Random().nextInt(6) + 4),
        )..repeat(),
      );
    }
  }

  void generateRandomLetterOptions() {
    final random = Random();
    selectedLetter = letters[random.nextInt(letters.length)];
    letterOptions = [selectedLetter];

    while (letterOptions.length < 4) {
      String randomLetter = letters[random.nextInt(letters.length)];
      if (!letterOptions.contains(randomLetter)) {
        letterOptions.add(randomLetter);
      }
    }

    letterOptions.shuffle();
    setState(() {});
  }

  void checkLetter(String chosenLetter, int letterIndex) async {
    if (isGameOver) return;

    await _playSound(letterSounds[letterIndex]);
    await _speak(letterOptions[letterIndex]);

    if (chosenLetter == selectedLetter) {
      await _playSound('audio/correct.mp3');
      _confettiController.play();
      setState(() {
        score++;
        attempts = 0;
        generateRandomLetterOptions();
      });
    } else {
      await _playSound('audio/incorrect.mp3');
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }
      setState(() {
        attempts++;
        if (attempts >= 3) {
          isGameOver = true;
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

  @override
  void dispose() {
    _confettiController.dispose();
    for (var controller in balloonControllers) {
      controller.dispose();
    }
    backgroundController.dispose();
    audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Select the Correct Letter!'),
          backgroundColor: Colors.blue[800],
        ),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: starAnimation ?? Tween<double>(begin: 0, end: 1).animate(backgroundController),
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/night_sky.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: CustomPaint(
                    painter: StarPainter(starAnimation?.value ?? 0),
                  ),
                );
              },
            ),
            if (!isGameOver)
              Stack(
                children: [
                  for (int i = 0; i < letterOptions.length; i++)
                    Positioned(
                      top: Random().nextDouble() * MediaQuery.of(context).size.height * 0.8,
                      left: Random().nextDouble() * MediaQuery.of(context).size.width * 0.8,
                      child: GestureDetector(
                        onTap: () => checkLetter(letterOptions[i], i),
                        child: AnimatedBuilder(
                          animation: balloonControllers[i],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -balloonControllers[i].value * 300),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/balloon.png',
                                height: 100,
                                width: 100,
                              ),
                              Text(
                                letterOptions[i],
                                style: const TextStyle(fontSize: 40, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            if (isGameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Game Over!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Final Score: $score',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score = 0;
                          attempts = 0;
                          isGameOver = false;
                          generateRandomLetterOptions();
                        });
                      },
                      child: const Text('Play Again'),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow],
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Attempts: $attempts/3',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final double animationValue;

  StarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = Random();
    for (int i = 0; i < 100; i++) {
      double dx = random.nextDouble() * size.width;
      double dy = (random.nextDouble() * size.height * 0.5) + (animationValue * size.height * 0.5);
      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
