import 'package:cloud_firestore/cloud_firestore.dart';

class ChoreCrud {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String aptId;

  ChoreCrud({required this.aptId});

  CollectionReference get _choresRef =>
      _db.collection('apartments').doc(aptId).collection('chores');

  // READ
  Stream<QuerySnapshot> getChoresStream(String? categoryFilter) {
    Query query = _choresRef;
    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter);
    }
    return query.snapshots();
  }

  // CREATE
  Future<void> addChore({
    required String title,
    required String assignedTo,
    required String category,
    String priority = 'Normal',
  }) {
    return _choresRef.add({
      'title': title,
      'assignedTo': assignedTo,
      'category': category,
      'priority': priority,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE (Toggle Done)
  Future<void> toggleChoreStatus(String choreId, bool isDone) {
    return _choresRef.doc(choreId).update({
      'isDone': isDone,
      'completedAt': isDone ? FieldValue.serverTimestamp() : null,
    });
  }

  // UPDATE (Edit)
  Future<void> updateChore(String choreId, Map<String, dynamic> data) {
    return _choresRef.doc(choreId).update(data);
  }

  // DELETE
  Future<void> deleteChore(String choreId) {
    return _choresRef.doc(choreId).delete();
  }
}
