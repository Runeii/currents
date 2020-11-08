import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currents/util.dart';

class Database {
  Future<DocumentSnapshot> artist(DocumentReference ref) {
    return ref.get();
  }

  Future<List<QueryDocumentSnapshot>> mediaByRefs(List refs) async {
    final splitRefs = splitList(refs, 10);
    final list = splitRefs
        .map<Future<QuerySnapshot>>(
          (refSet) => FirebaseFirestore.instance
              .collection('media')
              .where(FieldPath.documentId, whereIn: refSet)
              .get(),
        )
        .toList();
    final result = await Future.wait(list);
    return result.expand<QueryDocumentSnapshot>((list) => list.docs).toList();
  }

  Future<List<QueryDocumentSnapshot>> artistsByRefs(List refs) async {
    final splitRefs = splitList(refs, 10);
    final list = splitRefs
        .map<Future<QuerySnapshot>>(
          (refSet) => FirebaseFirestore.instance
              .collection('artists')
              .where(FieldPath.documentId, whereIn: refSet)
              .get(),
        )
        .toList();
    final result = await Future.wait(list);
    return result.expand<QueryDocumentSnapshot>((list) => list.docs).toList();
  }

  Stream<QuerySnapshot> posts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('media')
        .snapshots();
  }
}

final database = Database();
