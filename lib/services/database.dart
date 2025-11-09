import 'package:cloud_firestore/cloud_firestore.dart';

class Databasemethods {
  Future adduser(Map<String, dynamic> userinfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(id)
        .set(userinfoMap);
  }
}
