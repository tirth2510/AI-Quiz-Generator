import 'dart:io';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'mcq_results.dart'; // Import the MCQResults screen

class MCQGenerator extends StatefulWidget {
  @override
  _MCQGeneratorState createState() => _MCQGeneratorState();
}

class _MCQGeneratorState extends State<MCQGenerator> {
  File? _file;
  String? _textInput;
  int _numQuestions = 1;
  bool _isLoading = false;
  String _difficultyLevel = 'Easy'; // Default difficulty level

  final TextEditingController _textController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx'],
    );
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
        _textInput = null; // Clear text input when a file is picked
        _textController.clear(); // Clear the text field
      });
    }
  }

  Future<void> _generateMCQs() async {
    setState(() {
      _isLoading = true;
    });

    // Check if both file and text input are null
    if (_file == null && (_textInput == null || _textInput!.isEmpty)) {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
      // Show error message
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Please upload a file or enter text.')),
      );
      return; // Exit the function
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/generate'));

    if (_file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _file!.path,
        filename: basename(_file!.path),
      ));
    }

    // Only add text input if it exists
    if (_textInput != null && _textInput!.isNotEmpty) {
      request.fields['text'] = _textInput!;
    }

    request.fields['num_questions'] = _numQuestions.toString();
    request.fields['difficulty'] = _difficultyLevel; // Add difficulty level to the request

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String mcqs = jsonResponse['mcqs'];

        // Navigate to MCQResults screen with the generated MCQs
        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => MCQResults(
              mcqs: mcqs,
              pdfFilePath: 'path/to/pdf', // Provide a value for the pdfFilePath parameter
            ),
          ),
        );
      } else {
        var responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, Details: $responseBody');
      }
    } catch (e) {
      print('Failed to generate MCQs: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _deleteFile() {
    setState(() {
      _file = null; // Clear the selected file
      _textInput = null; // Optionally clear text input
      _textController.clear(); // Clear the text field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(child: Text('Generate MCQs from Your Text', style: TextStyle(fontSize: 24))),
            SizedBox(height: 20),

            // File Picker Button
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Upload your document (PDF, TXT, DOCX)'),
            ),

            if (_file != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Selected File: ${basename(_file!.path)}'),
              ),

            if (_file != null)
              ElevatedButton(
                onPressed: _deleteFile,
                child: Text('Delete Selected File'),
              ),

            if (_file == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  // Text Input
                  TextFormField(
                    controller: _textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Or enter text directly',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _textInput = value;
                      });
                    },
                  ),
                ],
              ),

            SizedBox(height: 20),

            // Number of Questions
            Text('How many questions do you want?', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextFormField(
              initialValue: '1',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _numQuestions = int.tryParse(value) ?? 1;
                });
              },
            ),

            SizedBox(height: 20),

            // Difficulty Level Dropdown
            Text('Select Difficulty Level', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _difficultyLevel,
              onChanged: (String? newValue) {
                setState(() {
                  _difficultyLevel = newValue!;
                });
              },
              items: <String>['Easy', 'Medium', 'Hard']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            SizedBox(height: 30),

            // Generate MCQs Button
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _generateMCQs,
                    child: Text('Generate MCQs'),
                  ),
          ],
        ),
      ),
    );
  }
}
