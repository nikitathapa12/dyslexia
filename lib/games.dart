import 'package:dyslearn/Games/LetterSelection/LetterSelectionGame.dart';
import 'package:dyslearn/Games/color_recognition_game/ColorMatchingGame.dart';
import 'package:dyslearn/Games/color_recognition_game/ColorRecognition.dart';
import 'package:dyslearn/Games/counting_number/CherryCountingGame.dart';
import 'package:dyslearn/Games/counting_number/CountingNumber.dart';
import 'package:dyslearn/Games/counting_number/StarCountingGame.dart';
import 'package:flutter/material.dart';

class GamesPage extends StatelessWidget {
  final String? selectedChildName;


  GamesPage({this.selectedChildName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Educational Games',
          style: TextStyle(fontFamily: 'ChalkStyle', fontSize: 24, color: Colors.grey),
        ),
        backgroundColor: Color(0xFFF7E7CE), // Calm, soothing color
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dyslexia_friendly_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.dstATop),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _GameCard(
              title: 'Color Recognition',
              image: 'assets/images/color_recognition.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColorRecognitionGame(selectedChildName: selectedChildName,)),
                );
              },
            ),
            _GameCard(
              title: 'Letter Selection',
              image: 'assets/images/letter.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LetterSelectionGame()),
                );
              },
            ),
            _GameCard(
              title: 'Counting Numbers',
              image: 'assets/images/num.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CherryCountingGame()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for each game card
class _GameCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  _GameCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        color: Colors.white, // Soft white background for the cards
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 20), // Spacing between image and text
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'ChalkStyle', // Updated fontFamily
                    fontSize: 24, // Larger, readable font size
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800], // Darker color for readability
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
