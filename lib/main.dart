import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mcqapp/mcq_code.dart';
import 'package:mcqapp/mcq_generator.dart';
import 'login.dart'; // Import the login.dart page

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
      home: FutureBuilder(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // Navigate directly based on the user data
            return snapshot.data!;
          }
          // If no user is logged in, show the login page
          return LoginPage();
        },
      ),
    );
  }

  Future<Widget> _checkUserLoggedIn() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If a user is logged in, navigate based on their role
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
      if (doc.exists) {
        var role = doc['role'];
        return role == 'teacher' ? MCQGenerator() : MCQCode();
      }
    }
    return LoginPage();
  }
}
