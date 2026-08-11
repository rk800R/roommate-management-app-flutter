import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  static const String aptId = 'default_apt';

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signUp(String email, String password, {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user != null) {
      // Persist user profile in Firestore
      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName ?? email.split('@').first,
        'apartmentId': aptId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(displayName);
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  // ─── Auth Helpers ──────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  String get displayName {
    final name = _auth.currentUser?.displayName;
    if (name != null && name.isNotEmpty) return name;
    return _auth.currentUser?.email?.split('@').first.toUpperCase() ?? 'USER';
  }

  String get email => _auth.currentUser?.email ?? 'No email';

  // ─── Real-time Dashboard (combines chores + expenses streams) ──────────────

  Stream<Map<String, dynamic>> dashboardStream(String aptId) {
    final choresStream =
        _db.collection('apartments').doc(aptId).collection('chores').snapshots();
    final expensesStream =
        _db.collection('apartments').doc(aptId).collection('expenses').snapshots();

    late StreamSubscription choreSub;
    late StreamSubscription expenseSub;
    final controller = StreamController<Map<String, dynamic>>();

    QuerySnapshot? lastChores;
    QuerySnapshot? lastExpenses;

    void emit() {
      if (lastChores == null || lastExpenses == null) return;

      int pendingChores = 0;
      int totalChores = lastChores!.docs.length;
      for (var doc in lastChores!.docs) {
        final data = doc.data() as Map;
        if (data['isDone'] != true) pendingChores++;
      }

      double outstanding = 0;
      int paidCount = 0;
      int pendingCount = 0;
      for (var exp in lastExpenses!.docs) {
        final data = exp.data() as Map;
        final breakdown = data['breakdown'] as Map? ?? {};
        for (var entry in breakdown.entries) {
          final personData = entry.value as Map;
          final status = personData['status'] ?? 'Pending';
          if (status == 'Pending') {
            outstanding += double.tryParse(personData['share']?.toString() ?? '0') ?? 0;
            pendingCount++;
          } else {
            paidCount++;
          }
        }
      }

      // Savings mock: completed chores × 50 (gamification)
      int savings = (totalChores - pendingChores) * 50;

      controller.add({
        'pendingChores': pendingChores,
        'totalChores': totalChores,
        'outstanding': outstanding.toStringAsFixed(2),
        'paid': paidCount,
        'pending': pendingCount,
        'savings': savings,
      });
    }

    controller.onListen = () {
      choreSub = choresStream.listen((snap) {
        lastChores = snap;
        emit();
      });
      expenseSub = expensesStream.listen((snap) {
        lastExpenses = snap;
        emit();
      });
    };

    controller.onCancel = () {
      choreSub.cancel();
      expenseSub.cancel();
    };

    return controller.stream;
  }
}