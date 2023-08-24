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

double calculateCosineSimilarity(
    List<double> embeddings1, List<double> embeddings2) {
  double dotProduct = 0;
  double norm1 = 0;
  double norm2 = 0;
  for (int i = 0; i < embeddings1.length; i++) {
    dotProduct += embeddings1[i] * embeddings1[i];
    norm1 += embeddings1[i] * embeddings1[i];
    norm2 += embeddings2[i] * embeddings2[i];
  }
  norm1 = sqrt(norm1);
  norm2 = sqrt(norm2);
  if (norm1 == 0 || norm2 == 0) {
    return 0;
  }
  return dotProduct / (norm1 * norm2);
}

void FaceMatchMethod(BuildContext context) {
  if (recognitionEmbeddings != null) {
    for (var data in dataList) {
      List<double>? storedEmbeddings = data['Embeddings'];
      if (storedEmbeddings != null) {
        double similarity =
            calculateCosineSimilarity(recognitionEmbeddings!, storedEmbeddings);
        double similarity2 =
            computeDistance(recognitionEmbeddings!, storedEmbeddings);
        print("Similarity:$similarity2");
        if (similarity2 < 0.4) {
          String name = data['name'];
          context.read<SelectedNameCubit>().updateSelectedName(name);

          print("Matching face found:$name");
        } else {
          print("No Faces Registerd");
        }
      } else {
        print("StoredEmbeddings is null");
      }
    }
  } else {
    print("Recognitized Embeddings Null");
  }
}

void loadModel() async {
  interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
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
