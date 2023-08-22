import 'package:face_recognition/src/Face_Recognition/faces_page.dart';
import 'package:face_recognition/src/Face_Recognition/methods.dart';
import 'package:face_recognition/src/Face_Recognition/recognition_page.dart';
import 'package:face_recognition/src/Face_Recognition/register_page.dart';
import 'package:flutter/material.dart';

class Face1 extends StatefulWidget {
  const Face1({super.key});

  @override
  State<Face1> createState() => _Face1State();
}

class _Face1State extends State<Face1> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image-recognition"),
        backgroundColor: Color.fromARGB(255, 14, 63, 92),
      ),
      body: Column(
        children: [
          Image.asset("assets/face_recog.jpg"),
          const SizedBox(
            height: 50,
          ),
          const SizedBox(
            width: 80,
          ),
          elvatedButton(
              context,
              "Register",
              300,
              50,
              const Color.fromARGB(255, 42, 95, 187),
              20,
              FontWeight.w600,
              18,
              Colors.white,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterFaces()))),
          const SizedBox(
            height: 50,
          ),
          elvatedButton(
              context,
              "Recognition",
              300,
              50,
              const Color.fromARGB(255, 42, 95, 187),
              20,
              FontWeight.w600,
              18,
              Colors.white,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RecognitionFaces()))),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisteredFaces()));
            },
            child: const Center(
              child: Text(
                "Show Registerd Faces",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(255, 42, 95, 187),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
