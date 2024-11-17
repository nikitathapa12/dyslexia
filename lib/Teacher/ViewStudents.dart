import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentViewPage extends StatefulWidget {
  @override
  _StudentViewPageState createState() => _StudentViewPageState();
}

class _StudentViewPageState extends State<StudentViewPage> {
  Map<String, List<String>> parentData = {}; // To store parent email and children data

  @override
  void initState() {
    super.initState();
    _fetchAllParentDetails();
  }

  // Fetch all parents and their children from Firestore
  Future<void> _fetchAllParentDetails() async {
    try {
      // Get all parent documents from the 'usernames' collection
      QuerySnapshot parentSnapshot =
      await FirebaseFirestore.instance.collection('usernames').get();

      Map<String, List<String>> fetchedParentData = {};

      // Iterate through each parent document
      for (var parentDoc in parentSnapshot.docs) {
        String parentEmail = parentDoc.id; // Parent email as the document ID
        print('Fetching data for Parent: $parentEmail');

        // Check if a `children` subcollection exists
        QuerySnapshot childrenSnapshot =
        await parentDoc.reference.collection('children').get();

        if (childrenSnapshot.docs.isNotEmpty) {
          // If the `children` subcollection exists, fetch its data
          List<String> childUsernames = childrenSnapshot.docs.map((childDoc) {
            final data = childDoc.data() as Map<String, dynamic>;
            return data['username']?.toString() ?? 'No username found';
          }).toList();

          fetchedParentData[parentEmail] = childUsernames;
        } else {
          // If no `children` subcollection, check if the `username` field exists directly in the parent document
          final parentData = parentDoc.data() as Map<String, dynamic>;
          if (parentData.containsKey('username')) {
            fetchedParentData[parentEmail] = [parentData['username']];
          } else {
            fetchedParentData[parentEmail] = ['No children found'];
          }
        }
      }

      setState(() {
        parentData = fetchedParentData;
      });
    } catch (e) {
      print('Error fetching parent data: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: parentData.isEmpty
            ? Center(
          child: CircularProgressIndicator(), // Loading indicator
        )
            : ListView.builder(
          itemCount: parentData.length,
          itemBuilder: (context, index) {
            String parentEmail = parentData.keys.elementAt(index);
            List<String> children = parentData[parentEmail]!;

            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parent Email: $parentEmail',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Children:',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...children.map((child) => Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '- $child',
                        style: TextStyle(fontSize: 14),
                      ),
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
