import 'package:cloud_firestore/cloud_firestore.dart';

/// CRUD for the apartment's chatrooms.
///
/// Layout:
///   apartments/{aptId}/chatrooms/{roomId}
///     ├─ name, isDefault, lastMessage, lastMessageAt, createdAt
///     └─ messages/{messageId}
///          └─ text, senderName, senderId, createdAt
class ChatCrud {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String aptId;

  ChatCrud({required this.aptId});

  CollectionReference get _roomsRef =>
      _db.collection('apartments').doc(aptId).collection('chatrooms');

  CollectionReference _messagesRef(String roomId) =>
      _roomsRef.doc(roomId).collection('messages');

  // ─── Rooms ──────────────────────────────────────────────────────────────────

  /// Real-time stream of chatrooms, most recently active first.
  Stream<QuerySnapshot> getRoomsStream() {
    return _roomsRef.orderBy('lastMessageAt', descending: true).snapshots();
  }

  /// Create the built-in "General" room on first run, if it doesn't exist yet.
  Future<void> ensureDefaultRoom() async {
    final snap = await _roomsRef.where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isEmpty) {
      await _roomsRef.add({
        'name': 'General',
        'isDefault': true,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Create a new chatroom and return its document id.
  Future<String> createRoom(String name) async {
    final ref = await _roomsRef.add({
      'name': name,
      'isDefault': false,
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ─── Messages ───────────────────────────────────────────────────────────────

  /// Real-time stream of a room's messages, newest first (capped at 200).
  Stream<QuerySnapshot> getMessagesStream(String roomId) {
    return _messagesRef(roomId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots();
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
    required String senderName,
    required String senderId,
  }) async {
    await _messagesRef(roomId).add({
      'text': text,
      'senderName': senderName,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Keep the room list's preview + ordering in sync with the newest message.
    await _roomsRef.doc(roomId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }
}
