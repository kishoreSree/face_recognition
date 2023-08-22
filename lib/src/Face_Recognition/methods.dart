import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

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
