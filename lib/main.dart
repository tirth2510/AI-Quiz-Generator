import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mcq_generator.dart'; // Import the mcq_generator.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MCQGenerator(), // Launch the MCQ Generator page
    );
  }
}
