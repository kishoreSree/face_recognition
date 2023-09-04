import 'dart:typed_data';

import 'package:face_recognition/src/Face_Recognition/bloc/namechange.dart';
import 'package:face_recognition/src/Face_Recognition/library_for_variables.dart';
import 'package:face_recognition/src/Face_Recognition/local_db.dart';
import 'package:face_recognition/src/Face_Recognition/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    as face;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class RecognitionFaces extends StatefulWidget {
  const RecognitionFaces({super.key});

  @override
  State<RecognitionFaces> createState() => _RecognitionFacesState();
}

class _RecognitionFacesState extends State<RecognitionFaces> {
  img.Image? fullface;
  void recognitionImage(bool camera) async {
    final pickedImage = camera
        ? await ImagePicker().pickImage(source: ImageSource.camera)
        : await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }
    final imagebytes = await pickedImage.readAsBytes();
    final decodedimage = img.decodeImage(Uint8List.fromList(imagebytes));
    setState(() {
      fullface = decodedimage;
      print(" Recognition Full Face Updated");
    });
    final inputimage = face.InputImage.fromFilePath(pickedImage.path);
    final face.FaceDetector faceDetector = face.FaceDetector(
        options: face.FaceDetectorOptions(
            enableTracking: true,
            enableContours: true,
            enableClassification: true,
            enableLandmarks: true,
            performanceMode: face.FaceDetectorMode.accurate));
    final List<face.Face> faces = await faceDetector.processImage(inputimage);
    if (faces.isNotEmpty) {
      print("Face detected");
      double widthPercentageToCrop = 0.36; // Adjust this value as needed
      double heightPercentageToCrop = 0.33; // Adjust this value as needed

      int newWidth =
          (faces[0].boundingBox.width * (1 - widthPercentageToCrop)).toInt();
      int xOffset = ((faces[0].boundingBox.width - newWidth) / 1.9).toInt();

      int newHeight =
          (faces[0].boundingBox.height * (1 - heightPercentageToCrop)).toInt();
      int yOffset = ((faces[0].boundingBox.height - newHeight) / 2).toInt();
      setState(() {
        recognitionFace = img.copyCrop(
            decodedimage!,
            faces[0].boundingBox.left.toInt() + xOffset,
            faces[0].boundingBox.top.toInt() + yOffset,
            newWidth,
            newHeight);
        print("Croped Face Updated");
      });
      if (recognitionFace != null) {
        recog(recognitionFace!);
      }
    } else {
      print("No Faces Datected");
      context.read<SelectedNameCubit>().updateSelectedName("");
    }
  }

  List<double> recog(img.Image? img) {
    List input = imageToByteListFloat32(img!, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 128, null, growable: false).reshape([1, 128]);
    interpreter!.run(input, output);
    output = output.reshape([128]);
    print("embrecog:${List.from(output)}");
    setState(() {
      recognitionEmbeddings = List.from(output);
      print("RecognitionEmbedddings Updated");
    });
    return List.from(output);
  }

  Future<void> retriveAndSetData() async {
    final retrivedData = await retriveStoredDates();
    setState(() {
      dataList = retrivedData;
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    retriveAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SelectedNameCubit>().resetSelectedName();
                setState(() {
                  recognitionFace = null;
                });
              },
              icon: Icon(Icons.arrow_back))
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 95, 187),
        title: const Text("Recognition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/recognition.webp"),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Choose camera for your face recognition:",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 42, 95, 187)),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.35, top: 10),
              child: Row(
                children: [
                  Card(
                    elevation: 7,
                    child: Container(
                      height: 50,
                      width: 70,
                      child: IconButton(
                          onPressed: () {
                            recognitionImage(true);
                          },
                          icon: Image.asset("assets/camera.png")),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Card(
                    elevation: 6,
                    child: Container(
                      height: 50,
                      width: 70,
                      child: IconButton(
                          onPressed: () {
                            recognitionImage(false);
                          },
                          icon: Image.asset("assets/gallary.png")),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (recognitionFace != null)
              Container(
                height: 300,
                width: double.infinity,
                child: Image.memory(
                    Uint8List.fromList(img.encodePng(recognitionFace!))),
              ),
            const SizedBox(
              height: 10,
            ),
            if (fullface != null)
              elvatedButton(
                  context,
                  "Get Matched Face",
                  70,
                  30,
                  Color.fromARGB(255, 42, 95, 187),
                  10,
                  FontWeight.w500,
                  17,
                  Colors.white, () {
                FaceMatchMethod(context);
                similarity(context);
              }),
            BlocBuilder<SelectedNameCubit, String>(
              builder: (context, name) {
                return Text("Matiching face:${name}");
              },
            ),
          ],
        ),
      ),
    );
  }
}
