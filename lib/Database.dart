import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('transactions');

class Database {
  static String? userUid;

  static Future<void> addItem({
    required String title,
    required String description,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('transactions').doc();

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
    };

    await documentReferencer
        .set(data)
        .whenComplete(() => print("Заметка добавлена в базу"))
        .catchError((e) => print(e));
  }

  static Stream<QuerySnapshot> readItems() {
    CollectionReference notesItemCollection =
    _mainCollection.doc(userUid).collection('transactions');

    return notesItemCollection.snapshots();
  }

  static Future<void> updateItem({
    required String title,
    required String description,
    required String docId,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('transactions').doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Заметка в базе успешно обновлена"))
        .catchError((e) => print(e));
  }

  static Future<void> deleteItem({
    required String docId,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('transactions').doc(docId);

    await documentReferencer
        .delete()
        .whenComplete(() => print('Заметка успешно удалена из базы'))
        .catchError((e) => print(e));
  }
}