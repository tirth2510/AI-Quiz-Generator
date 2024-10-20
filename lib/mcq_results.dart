import 'package:flutter/material.dart';

class MCQResults extends StatelessWidget {
  final String mcqs;

  MCQResults({required this.mcqs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated MCQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Here are your generated MCQs:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(mcqs, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
