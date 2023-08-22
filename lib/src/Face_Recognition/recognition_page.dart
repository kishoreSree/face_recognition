import 'package:flutter/material.dart';

class RecognitionFaces extends StatefulWidget {
  const RecognitionFaces({super.key});

  @override
  State<RecognitionFaces> createState() => _RecognitionFacesState();
}

class _RecognitionFacesState extends State<RecognitionFaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 95, 187),
        title: const Text("Recognition"),
      ),
    );
  }
}
