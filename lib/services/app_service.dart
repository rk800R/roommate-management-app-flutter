import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/HomeScreen.dart';

class AppService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Auth (Screen 1)
  Future<User?> login(String e, String p) => _auth.signInWithEmailAndPassword(email: e, password: p).then((r) => r.user);
  Future<User?> signUp(String e, String p) => _auth.createUserWithEmailAndPassword(email: e, password: p).then((r) => r.user);
 

  // Real-time Dashboard
  Stream<Map<String, dynamic>> dashboardStream(String aptId) =>
      _db.collection('apartments').doc(aptId).snapshots().map((s) => s.data() ?? {});

  // Auth Helpers
  User? get currentUser => _auth.currentUser;
  String get displayName => _auth.currentUser?.email?.split('@').first.toUpperCase() ?? 'USER';
  Future<void> signOut() => _auth.signOut();
}
