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
          child: SelectableText(
            mcqs,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
