import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

img.Image? registeringFace;
img.Image? recognitionFace;
List<double>? registeredembeddings;
List<double>? recognitionEmbeddings;
List<Map<dynamic, dynamic>> dataList = [];
String names = "";
Interpreter? interpreter;
List<double> similarities = [];
List<int> indices = [];
bool? isUnregistered;
