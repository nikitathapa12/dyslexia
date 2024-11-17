// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(CountingGame());
// }
//
// class CountingGame extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GameScreen(),
//     );
//   }
// }
//
// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> {
//   int _currentNumber = 1;
//   int _targetNumber = 10;
//   int _score = 0;
//
//   void _incrementNumber() {
//     setState(() {
//       if (_currentNumber == _targetNumber) {
//         _score++;
//         _currentNumber = 1;
//         _targetNumber = (_targetNumber % 10) + 1;  // Changed targetNumber to _targetNumber
//       } else {
//         _currentNumber++;
//       }
//     });
//   }
//
//   void _resetGame() {
//     setState(() {
//       _currentNumber = 1;
//       _score = 0;
//       _targetNumber = 100000;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Counting Game'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _resetGame,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Current Number: $_currentNumber',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _incrementNumber,
//               child: Text(
//                 'Count',
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Score: $_score',
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
