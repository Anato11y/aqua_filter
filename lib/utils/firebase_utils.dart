import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtils {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addData(
      String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  static Stream<QuerySnapshot> getDataStream(String collection) {
    return _db.collection(collection).snapshots();
  }
}
