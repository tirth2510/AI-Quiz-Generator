import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MCQResults extends StatelessWidget {
  final String mcqs;
  final String pdfFilePath; // New parameter for PDF file path

  MCQResults({required this.mcqs, required this.pdfFilePath}); // Modify constructor

  Future<void> _downloadPDF() async {
    final url = Uri.parse(pdfFilePath);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split the MCQs into separate questions
    final List<String> questions = mcqs.split('## MCQ').where((q) => q.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Generated MCQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: questions.map((question) {
              // Further split each question into parts
              final lines = question.trim().split('\n');

              // Find the indices of where the options start (A, B, C, D)
              int questionEndIndex = 0;
              for (int i = 0; i < lines.length; i++) {
                if (lines[i].startsWith('A)')) {
                  questionEndIndex = i; // The line before A) is the end of the question
                  break;
                }
              }

              // Combine all lines before A) as the question
              final questionText = lines.sublist(0, questionEndIndex).join('\n').replaceFirst('Question: ', '');

              // Extract options
              final optionA = lines[questionEndIndex].replaceFirst('A) ', '');
              final optionB = lines[questionEndIndex + 1].replaceFirst('B) ', '');
              final optionC = lines[questionEndIndex + 2].replaceFirst('C) ', '');
              final optionD = lines[questionEndIndex + 3].replaceFirst('D) ', '');
              final correctAnswer = lines.last.replaceFirst('', '');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionText,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('A) $optionA'),
                      Text('B) $optionB'),
                      Text('C) $optionC'),
                      Text('D) $optionD'),
                      SizedBox(height: 10),
                      Text(
                        '$correctAnswer',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadPDF,
        tooltip: 'Download PDF',
        child: Icon(Icons.file_download),
      ),
    );
  }
}
