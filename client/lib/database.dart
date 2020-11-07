import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  Future<DocumentSnapshot> artist(DocumentReference ref) {
    return ref.get();
  }

  Stream<QuerySnapshot> posts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('media')
        .snapshots();
  }
}

final database = Database();
