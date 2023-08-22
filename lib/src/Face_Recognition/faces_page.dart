import 'package:face_recognition/src/Face_Recognition/local_db.dart';
import 'package:face_recognition/src/Face_Recognition/methods.dart';
import 'package:flutter/material.dart';

class RegisteredFaces extends StatefulWidget {
  const RegisteredFaces({super.key});

  @override
  State<RegisteredFaces> createState() => _RegisteredFacesState();
}

class _RegisteredFacesState extends State<RegisteredFaces> {
  List<Map<dynamic, dynamic>> dataList = [];

  Future<void> retriveAndSetData() async {
    final retrivedData = await retriveStoredDates();
    setState(() {
      dataList = retrivedData;
    });
  }

  @override
  void initState() {
    super.initState();
    retriveAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 95, 187),
        title: const Text("Registered Faces"),
      ),
      body: Column(
        children: [
          elvatedButton(
              context,
              "Clear_DB",
              200,
              40,
              const Color.fromARGB(255, 42, 95, 187),
              15,
              FontWeight.w600,
              16,
              Colors.white,
              () => closeHiveDB()),
          const SizedBox(
            height: 30,
          ),
         const Divider(
            thickness: 2,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const Text(
                "Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 42, 95, 187),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              const Text(
                "Embeddings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 42, 95, 187),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 2,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final name = dataList[index]['name'];
                  final embeddings = dataList[index]['Embeddings'];
                  return Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Text(name),
                          Spacer(),
                          Container(
                              height: 30,
                              width: 100,
                              child: Text(embeddings.toString())),
                          const SizedBox(
                            width: 60,
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
