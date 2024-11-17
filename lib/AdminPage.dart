// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
//
// class AdminPage extends StatefulWidget {
//   @override
//   _AdminPageState createState() => _AdminPageState();
// }
//
// class _AdminPageState extends State<AdminPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   File? _assignmentFile;
//   String _assignmentTitle = '';
//
//   Future<void> _pickFile() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       setState(() {
//         _assignmentFile = File(file.path);
//       });
//     }
//   }
//
//   Future<void> _uploadAssignment() async {
//     if (_assignmentFile != null && _assignmentTitle.isNotEmpty) {
//       // Upload file to Firebase Storage
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference ref = _storage.ref().child('assignments/$fileName');
//       await ref.putFile(_assignmentFile!);
//
//       // Get download URL
//       String downloadURL = await ref.getDownloadURL();
//
//       // Save assignment info to Firestore
//       await _firestore.collection('assignments').add({
//         'title': _assignmentTitle,
//         'url': downloadURL,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // Clear fields
//       setState(() {
//         _assignmentFile = null;
//         _assignmentTitle = '';
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Assignment uploaded successfully!'),
//       ));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please select a file and enter a title.'),
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Page'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Assignment Title'),
//               onChanged: (value) {
//                 setState(() {
//                   _assignmentTitle = value;
//                 });
//               },
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _pickFile,
//               child: Text('Pick Assignment File'),
//             ),
//             SizedBox(height: 10),
//             _assignmentFile != null
//                 ? Text('Selected File: ${_assignmentFile!.path.split('/').last}')
//                 : Text('No file selected.'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _uploadAssignment,
//               child: Text('Upload Assignment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
