import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeCrud {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String aptId;

  NoticeCrud({required this.aptId});

  CollectionReference get _noticesRef =>
      _db.collection('apartments').doc(aptId).collection('notices');

  // READ — real-time stream ordered by newest first
  Stream<QuerySnapshot> getNoticesStream() {
    return _noticesRef.orderBy('createdAt', descending: true).snapshots();
  }

  // CREATE
  Future<void> addNotice({
    required String title,
    required String content,
    required String author,
    required String authorId,
  }) {
    return _noticesRef.add({
      'title': title,
      'content': content,
      'author': author,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> deleteNotice(String noticeId) {
    return _noticesRef.doc(noticeId).delete();
  }
}