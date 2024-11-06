import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mcq_generator.dart'; // Import the MCQ generator page
import 'mcq_code.dart'; // Import the MCQ code page

class MCQSelectionPage extends StatelessWidget {
  final User user;

  MCQSelectionPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Role")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Set role as teacher in Firestore
              await FirebaseFirestore.instance.collection('users').doc(user.email).update({
                'role': 'teacher',
              });

              // Navigate to MCQ generator page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MCQGenerator()),
              );
            },
            child: Text("Login as Teacher"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Set role as student in Firestore
              await FirebaseFirestore.instance.collection('users').doc(user.email).update({
                'role': 'student',
              });

              // Navigate to MCQ code page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MCQCode()),
              );
            },
            child: Text("Login as Student"),
          ),
        ],
      ),
    );
  }
}
