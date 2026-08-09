import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Auth (Screen 1)
  Future<User?> login(String e, String p) => _auth.signInWithEmailAndPassword(email: e, password: p).then((r) => r.user);
  Future<User?> signUp(String e, String p) => _auth.createUserWithEmailAndPassword(email: e, password: p).then((r) => r.user);
  
  // Real-time Dashboard (Screen 2)
  Stream<Map<String, dynamic>> dashboardStream(String aptId) =>
      _db.collection('apartments').doc(aptId).snapshots().map((s) => s.data() ?? {});

  // Chores CRUD (Screen 3)
  Stream<QuerySnapshot> choresStream(String aptId, String? category) {
    Query query = _db.collection('apartments').doc(aptId).collection('chores');
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots();
  }

  Future<void> toggleChore(String aptId, String choreId, bool done) =>
      _db.collection('apartments').doc(aptId).collection('chores')
         .doc(choreId).update({'isDone': done});

  // Backward compatibility / convenience
  User? get currentUser => _auth.currentUser;
  Future<void> signOut() => _auth.signOut();
}
