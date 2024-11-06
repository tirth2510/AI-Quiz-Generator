import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mcq_generator.dart';
import 'mcq_code.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool _isLoading = false;

  Future<User?> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setState(() {
        _isLoading = false;
      });
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      await _saveUserToFirestore(user);
    }

    setState(() {
      _isLoading = false;
    });

    return user;
  }

  Future<void> _saveUserToFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.email);

    final isTeacher = await _showRoleSelectionDialog();
    await userRef.set({
      'email': user.email,
      'role': isTeacher ? 'teacher' : 'student',
    });
  }

  Future<bool> _showRoleSelectionDialog() async {
    bool isTeacher = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Teacher'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: isTeacher,
                  onChanged: (bool? value) {
                    setState(() {
                      isTeacher = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Student'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: isTeacher,
                  onChanged: (bool? value) {
                    setState(() {
                      isTeacher = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return isTeacher;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  User? user = await _signInWithGoogle();
                  if (user != null) {
                    // Navigate to the next screen based on role
                    FirebaseFirestore.instance.collection('users').doc(user.email).get().then((doc) {
                      if (doc.exists) {
                        var role = doc['role'];
                        if (role == 'teacher') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MCQGenerator()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MCQCode()),
                          );
                        }
                      }
                    });
                  }
                },
                child: Text('Sign In with Google'),
              ),
      ),
    );
  }
}
