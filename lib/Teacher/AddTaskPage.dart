import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  String _taskDescription = '';
  String _taskType = 'Game Assignment'; // Default task type
  String? _selectedGameType; // Memory Game, Word Puzzle, Math Game
  File? _image;
  final picker = ImagePicker();

  List<String> _wordPuzzleWords = []; // List for word puzzle words
  String _newWord = ''; // Temp word input

  List<File> _memoryGameImages = []; // For memory game images
  List<String> _mathEquations = []; // For math game equations

  // Function to add task to Firestore
  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Prepare data to save
        Map<String, dynamic> taskData = {
          'title': _taskTitle,
          'description': _taskDescription,
          'task_type': _taskType,
          'game_type': _selectedGameType,
          'created_at': Timestamp.now(),
        };

        // Depending on game type, add the specific data
        if (_selectedGameType == 'Memory Game') {
          taskData['memory_images'] = _memoryGameImages.map((image) => image.path).toList();
        } else if (_selectedGameType == 'Word Puzzle') {
          taskData['word_puzzle_words'] = _wordPuzzleWords;
        } else if (_selectedGameType == 'Math Game') {
          taskData['math_equations'] = _mathEquations;
        }

        // Add task to Firestore
        await FirebaseFirestore.instance.collection('tasks').add(taskData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added successfully!')),
        );

        // Reset the form
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _memoryGameImages.clear();
          _wordPuzzleWords.clear();
          _mathEquations.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }
  }

  // Function to pick multiple images for memory game
  Future<void> _pickMemoryGameImages() async {
    if (await Permission.storage.request().isGranted) {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _memoryGameImages = pickedFiles.map((e) => File(e.path)).toList();
        });
      }
    }
  }

  // Function to add new word for Word Puzzle
  void _addWordToPuzzle() {
    if (_newWord.isNotEmpty) {
      setState(() {
        _wordPuzzleWords.add(_newWord);
        _newWord = ''; // Clear input after adding
      });
    }
  }

  // Function to add math equation for Math Game
  void _addMathEquation(String equation) {
    if (equation.isNotEmpty) {
      setState(() {
        _mathEquations.add(equation);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown for selecting task type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Task Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _taskType,
                  items: [
                    DropdownMenuItem(
                      value: 'Game Assignment',
                      child: Text('Game Assignment'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _taskType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Dropdown for selecting game type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Game Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedGameType,
                  items: [
                    DropdownMenuItem(
                      value: 'Memory Game',
                      child: Text('Memory Game'),
                    ),
                    DropdownMenuItem(
                      value: 'Word Puzzle',
                      child: Text('Word Puzzle'),
                    ),
                    DropdownMenuItem(
                      value: 'Math Game',
                      child: Text('Math Game'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGameType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Show fields based on selected game type
                if (_selectedGameType == 'Memory Game')
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _pickMemoryGameImages,
                        child: Text('Select Memory Game Images'),
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _memoryGameImages
                            .map((image) => Image.file(
                          image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ))
                            .toList(),
                      ),
                    ],
                  ),

                if (_selectedGameType == 'Word Puzzle')
                  Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Enter Word for Puzzle',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _newWord = value;
                        },
                      ),
                      ElevatedButton(
                        onPressed: _addWordToPuzzle,
                        child: Text('Add Word'),
                      ),
                      Wrap(
                        spacing: 8,
                        children: _wordPuzzleWords
                            .map((word) => Chip(
                          label: Text(word),
                        ))
                            .toList(),
                      ),
                    ],
                  ),

                if (_selectedGameType == 'Math Game')
                  Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Enter Math Equation',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (value) {
                          _addMathEquation(value);
                        },
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: _mathEquations
                            .map((equation) => Chip(
                          label: Text(equation),
                        ))
                            .toList(),
                      ),
                    ],
                  ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}