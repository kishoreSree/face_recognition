import 'package:face_recognition/src/Face_Recognition/library_for_variables.dart';
import 'package:face_recognition/src/Face_Recognition/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
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
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Future<void> alertBox(BuildContext ctx) async {
    showDialog(
        context: context,
        builder: (ctx) => Container(
              height: 350,
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
                  child: Form(
                    key: formkey,
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
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'name',
                              border: InputBorder.none),
                          controller: registerdingNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter a name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.deepOrange)),
                      onPressed: () {
                        if (formkey.currentState!.validate() &&
                            registeringFace != null &&
                            registerdingNameController.text.isNotEmpty) {
                          recog(registeringFace!);
                        }
                        storingData(
                          registerdingNameController.text,
                          registeredembeddings!,
                        );
                        setState(() {
                          registerdingNameController.text = "";
                        });
                        back(context);
                      },
                      child: Text("Register")),
                ],
              ),
            ));
  }

  void back(BuildContext context) {
    Navigator.pop(context, true);
  }

  int calculateBytesPerRow(int width, InputImageFormat format) {
    if (format == InputImageFormat.nv21) {
      return width + ((width + 1) ~/ 2) * 2;
    } else {
      return width;
    }
  }

  Future<void> pickImage(bool camera) async {
    final pickedImage = camera
        ? await ImagePicker().pickImage(source: ImageSource.camera)
        : await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }

    final imagebytes = await pickedImage.readAsBytes();
    final decodedimage = img.decodeImage(Uint8List.fromList(imagebytes));
    if (decodedimage == null) {
      return;
    }
    final WriteBuffer allBytes = WriteBuffer();
    final rotatedImage = img.copyRotate(decodedimage, 90);

    setState(() {
      Fullface = rotatedImage;
      
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
    try {
      final List<face.Face> faces = await faceDetector.processImage(inputimage);
      print("Face.length:${faces.length}");
      if (faces.isNotEmpty) {
        double widthPercentageToCrop = 0.36;
        double heightPercentageToCrop = 0.33;

        int newWidth =
            (faces[0].boundingBox.width * (1 - widthPercentageToCrop)).toInt();
        int xOffset = ((faces[0].boundingBox.width - newWidth) / 1.9).toInt();

        int newHeight =
            (faces[0].boundingBox.height * (1 - heightPercentageToCrop))
                .toInt();
        int yOffset = ((faces[0].boundingBox.height - newHeight) / 2).toInt();
        setState(() {
          registeringFace = img.copyCrop(
              decodedimage,
              faces[0].boundingBox.left.toInt() + xOffset,
              faces[0].boundingBox.top.toInt() + yOffset,
              newWidth,
              newHeight);
          print("Croped Face Updated");
          noFace = false;
        });
        callalert();
      } else {
        print("No faces");
        setState(() {
          noFace = true;
        });
      }
    } catch (e) {
      print("errror:$e");
    }
  }

  void callalert() async {
    if (!noFace) {
      alertBox(context);
    }
  }

  List<double> recog(img.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 128, null, growable: false)
        .reshape([1, 128]); //192-mobilefacenet
    if (interpreter != null) {}
    interpreter!.run(input, output);
    output = output.reshape([128]); //192-mobilefacenet

    setState(() {
      registeredembeddings = List.from(output);
    });
    return List.from(output);
  }

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
      body: SingleChildScrollView(
        child: Column(
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    height: 50,
                    width: 70,
                    child: IconButton(
                        onPressed: () async {
                          await pickImage(true);
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
                        onPressed: () async {
                          await pickImage(false);
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
      ),
    );
  }
}
