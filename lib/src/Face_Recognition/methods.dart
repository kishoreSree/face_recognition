import 'dart:math';
import 'dart:typed_data';

import 'package:face_recognition/src/Face_Recognition/bloc/namechange.dart';
import 'package:face_recognition/src/Face_Recognition/library_for_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

Widget elvatedButton(
  BuildContext context,
  String text,
  double btwidth,
  double btheight,
  Color btcolor,
  double btradius,
  FontWeight fontWeight,
  double fontSize,
  Color colors,
  // Function(BuildContext)? buildingPage,
  Function()? onPressed,
) {
  return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(btwidth, btheight)),
        backgroundColor: MaterialStateProperty.all<Color?>(btcolor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(btradius))),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
            color: colors, fontWeight: fontWeight, fontSize: fontSize),
      ));
}

Float32List imageToFloat32List(img.Image image) {
  var convertedBytes = Float32List(1 * image.width * image.height * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (int i = 0; i < image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      int pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (img.getRed(pixel)) / 255.0;
      buffer[pixelIndex++] = (img.getGreen(pixel)) / 255.0;
      buffer[pixelIndex++] = (img.getBlue(pixel)) / 255.0;
    }
  }
  print(convertedBytes);
  return convertedBytes;
}

Float32List imageToByteListFloat32(
    img.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asFloat32List();
}

void FaceMatchMethod(BuildContext context) {
  similarities.clear();
  indices.clear();
  bool allSimilaritiesAboveThreshold = true;
  if (recognitionEmbeddings != null) {
    for (int i = 0; i < dataList.length; i++) {
      List<double>? storedEmbeddings = dataList[i]['Embeddings'];
      if (storedEmbeddings != null) {
        double similarity2 =
            computeDistance(recognitionEmbeddings!, storedEmbeddings);
        similarities.add(similarity2);
        indices.add(i);

        print("Similarity:$similarity2");
        if (similarity2 < 2.0) {
          String name = dataList[i]['name'];
          print("Matching face found:$name");
          allSimilaritiesAboveThreshold = false;
          isUnregistered = false;
        } else {
          print("No Faces Registerd");
          // context
          //     .read<SelectedNameCubit>()
          //     .updateSelectedName("Unregisterd face");
        }
      } else {
        print("StoredEmbeddings is null");
        context
            .read<SelectedNameCubit>()
            .updateSelectedName("StoredEmbeddings is null");
      }
    }
    if (allSimilaritiesAboveThreshold) {
      isUnregistered = true;
      context.read<SelectedNameCubit>().updateSelectedName("Unregistered Face");
      print("Unregistered face found");
    }
  } else {
    print("Recognitized Embeddings Null");
    context
        .read<SelectedNameCubit>()
        .updateSelectedName("Recognitized Embeddings Null");
  }
}

void similarity(BuildContext context) {
  if (similarities.isNotEmpty && indices.isNotEmpty) {
    print("similarities:$similarities");

    double minSimilarity = similarities[0];

    int minIndex = indices[0];

    for (int i = 1; i < similarities.length; i++) {
      if (similarities[i] < minSimilarity) {
        minSimilarity = similarities[i];
        minIndex = indices[i];
      }
    }
    print("minsimilarity:$minSimilarity");
    print("Index:$minIndex");

    String name = dataList[minIndex]['name'];
    print("Matching face found:$name");

    isUnregistered == false
        ? context.read<SelectedNameCubit>().updateSelectedName(name)
        : "";
  }
}

void loadModel() async {
  interpreter = await Interpreter.fromAsset('assets/facenet.tflite');
  if (interpreter != null) {
    print("Model Loaded");
  }
}

double computeDistance(List<double> emb1, List<double> emb2) {
  double sum = 0;
  for (int i = 0; i < emb1.length; i++) {
    sum += (emb1[i] - emb2[i]) * (emb1[i] - emb2[i]);
  }
  return sqrt(sum);
}
