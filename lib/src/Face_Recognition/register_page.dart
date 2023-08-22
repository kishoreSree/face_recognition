import 'package:face_recognition/src/Face_Recognition/library_for_variables.dart';
import 'package:face_recognition/src/Face_Recognition/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    as face;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'local_db.dart';

class RegisterFaces extends StatefulWidget {
  const RegisterFaces({super.key});

  @override
  State<RegisterFaces> createState() => _RegisterFacesState();
}

class _RegisterFacesState extends State<RegisterFaces> {
  img.Image? Fullface;
  bool noFace = false;
  TextEditingController registerdingNameController = TextEditingController();
  Interpreter? interpreter;
  void alertBox(BuildContext ctx) {
    showDialog(
        context: context,
        builder: (ctx) => Container(
              height: 300,
              child: AlertDialog(
                title: const Text(
                  "Are You sure To Register This Face",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Container(
                  height: 300,
                  width: 200,
                  child: Column(
                    children: [
                      registeringFace != null
                          ? Container(
                              height: 200,
                              width: 200,
                              child: Image.memory(Uint8List.fromList(
                                  img.encodePng(registeringFace!))),
                            )
                          : const Center(child: CircularProgressIndicator()),
                      Card(
                        elevation: 6,
                        child: TextField(
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'name',
                              border: InputBorder.none),
                          controller: registerdingNameController,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.deepOrange)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (registeringFace != null) {
                          recog(registeringFace!);
                        }
                        storingData(
                          registerdingNameController.text,
                          registeredembeddings!,
                        );
                        setState(() {
                          registerdingNameController.text = "";
                        });
                      },
                      child: Text("Register")),
                ],
              ),
            ));
  }

  pickImage(bool camera) async {
    final pickedImage = camera
        ? await ImagePicker().pickImage(source: ImageSource.camera)
        : await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }

    final imagebytes = await pickedImage.readAsBytes();
    final decodedimage = img.decodeImage(Uint8List.fromList(imagebytes));
    setState(() {
      Fullface = decodedimage;
      print("Full Face Updated");
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
    int newWidth = (faces[0].boundingBox.width * 0.8).toInt();
    int xOffset = ((faces[0].boundingBox.width - newWidth) / 2).toInt();

    int newHeight = (faces[0].boundingBox.height * 0.8).toInt();
    int yOffset = ((faces[0].boundingBox.height - newHeight) / 2).toInt();
    if (faces.isNotEmpty) {
      print("Face ok");
      setState(() {
        registeringFace = img.copyCrop(
            decodedimage!,
            faces[0].boundingBox.left.toInt() + xOffset,
            faces[0].boundingBox.top.toInt() + yOffset,
            newWidth,
            newHeight);
        print("Croped Face Updated");
        noFace = false;
      });
      if (!noFace) {
        alertBox(context);
      }
    } else {
      print("No faces");
      setState(() {
        noFace = true;
      });
      return false;
    }
  }

  void loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
    if (interpreter != null) {
      print("Model Loaded");
    }
  }

  List<double> recog(img.Image img) {
    // imageToFloat32List(img);
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    if (interpreter != null) {}
    interpreter!.run(input, output);
    output = output.reshape([192]);
    // print("emb1:${List.from(output)}");
    setState(() {
      registeredembeddings = List.from(output);
    });
    return List.from(output);
  }

  // List<double> GenerateEmbeddings(img.Image image) {
  //   Float32List input = imageToByteListFloat32(image, 112, 128, 128);
  //   input = input.reshape([1, 112, 112, 3]);
  // }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 95, 187),
        title: const Text("Register Your Face"),
      ),
      body: Column(
        children: [
          Fullface == null
              ? Image.asset("assets/face_gif.gif")
              : Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.memory(
                      Uint8List.fromList(img.encodePng(Fullface!))),
                ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "Choose your way to Register:",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              const SizedBox(
                width: 100,
              ),
              Card(
                elevation: 6,
                child: Container(
                  height: 50,
                  width: 70,
                  child: IconButton(
                      onPressed: () {
                        pickImage(true);
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
                        pickImage(false);
                      },
                      icon: Image.asset("assets/gallary.png")),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          noFace ? const Text("No Face Detected") : const Text(""),
        ],
      ),
    );
  }
}
