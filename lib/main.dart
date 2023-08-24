import 'package:face_recognition/src/Face_Recognition/bloc/namechange.dart';
import 'package:face_recognition/src/Face_Recognition/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('faceRecognitionDatas');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectedNameCubit(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Face1(),
      ),
    );
  }
}
