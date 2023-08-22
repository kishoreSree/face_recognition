import 'package:hive/hive.dart';

void storingData(String name, List<double> embeddings) async {
  try {
    final localDb = await Hive.openBox('faceRecognitionDatas');
    //final imagebytes = Uint8List.fromList(img.encodePng(RegisteringFace!));

    final data = {
      'name': name,
      'Embeddings': embeddings,
    };
    print("name:$name");
    print("emb:$embeddings");
    await localDb.add(data);
    print("data Stored");
  } catch (e) {
    print("error:${e}");
  }
}

Future<List<Map<dynamic, dynamic>>> retriveStoredDates() async {
  final localDb = await Hive.openBox('faceRecognitionDatas');
  final List<Map<dynamic, dynamic>> dataList = [];
  for (int i = 0; i < localDb.length; i++) {
    dataList.add(localDb.getAt(i));
  }
  return dataList;
}

Future<void> closeHiveDB() async {
  await Hive.close();
  await Hive.deleteBoxFromDisk('faceRecognitionDatas');
  print("DB cleared");
}
