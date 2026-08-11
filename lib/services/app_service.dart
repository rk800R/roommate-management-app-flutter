import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  static const String aptId = 'default_apt';

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null) {
      await ensureCurrentUserProfile();
    }
    return cred.user;
  }

  Future<User?> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      final cleanName = _displayNameFor(
        email: trimmedEmail,
        requestedName: displayName,
      );
      await user.updateDisplayName(cleanName);
      await _ensureUserProfile(user, displayName: cleanName);
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

  String? get currentUserId => _auth.currentUser?.uid;

  /// Creates or repairs the signed-in user's Firestore profile.
  ///
  /// Firebase Auth can contain users that do not yet have a matching
  /// `users/{uid}` document. The app uses that Firestore document as the member
  /// record, so every signed-in user needs one.
  Future<void> ensureCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _ensureUserProfile(user);
  }

  // ─── Members (current apartment, stored as real Firestore users) ───────────

  /// Real-time stream of every user whose Firestore `users/{uid}` doc belongs
  /// to this apartment. These are the "current members stored in Firebase".
  Stream<List<Map<String, dynamic>>> membersStream(String aptId) {
    return _db.collection('users').snapshots().map((snap) {
      final members = snap.docs
          .where((doc) => _belongsToApartment(doc.data(), aptId))
          .map(_memberFromDoc)
          .toList();
      _sortMembers(members);
      return members;
    });
  }

  /// One-off fetch of the current apartment's members, mapped to lightweight
  /// `{id, displayName, email}` maps — handy for dropdowns/dialogs.
  Future<List<Map<String, dynamic>>> getMembers(String aptId) async {
    final snap = await _db.collection('users').get();
    final members = snap.docs
        .where((doc) => _belongsToApartment(doc.data(), aptId))
        .map(_memberFromDoc)
        .toList();
    _sortMembers(members);
    return members;
  }

  // ─── Profile ────────────────────────────────────────────────────────────────

  /// Real-time stream of the current user's Firestore doc, so profile edits
  /// reflect in the UI as soon as they're saved.
  Stream<DocumentSnapshot<Map<String, dynamic>>> currentUserStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Update the current user's display name in both Firestore and Firebase Auth.
  ///
  /// The Firestore `users/{uid}` document is the source of truth for the UI,
  /// so it is written first and the Firebase Auth record is kept in sync after
  /// it. `set` with merge is used (instead of `update`) so the write also works
  /// when the profile document has not been created yet — `update()` would
  /// throw "no document to update" and the name change would silently fail.
  Future<void> updateProfile({required String displayName}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Make sure the profile document exists (seeds email/apartmentId) so the
    // user stays in the member list and the write below always has a target.
    await ensureCurrentUserProfile();

    // Write the new name in a single atomic merge so it is guaranteed to be
    // the final value for displayName on the document.
    await _db.collection('users').doc(user.uid).set(
          {
            'displayName': displayName,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

    // Keep Firebase Auth's displayName in sync. Auth is not the source of
    // truth for this screen, so a transient auth failure must not undo the
    // Firestore change already applied above.
    try {
      await user.updateDisplayName(displayName);
    } catch (_) {
      // Ignore — the Firestore name is already saved and is what the UI shows.
    }
  }

  // ─── Real-time Dashboard (combines chores + expenses streams) ──────────────

  Stream<Map<String, dynamic>> dashboardStream(String aptId) {
    final choresStream = _db
        .collection('apartments')
        .doc(aptId)
        .collection('chores')
        .snapshots();
    final expensesStream = _db
        .collection('apartments')
        .doc(aptId)
        .collection('expenses')
        .snapshots();

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
            outstanding +=
                double.tryParse(personData['share']?.toString() ?? '0') ?? 0;
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

  Future<void> _ensureUserProfile(User user, {String? displayName}) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    final existing = snap.data() ?? {};
    final currentApartmentId = existing['apartmentId']?.toString().trim();
    final cleanName = _displayNameFor(
      email: user.email,
      requestedName: displayName ?? user.displayName,
    );

    final profile = <String, dynamic>{
      'email': user.email ?? existing['email'] ?? '',
      'displayName':
          existing['displayName']?.toString().trim().isNotEmpty == true
          ? existing['displayName'].toString()
          : cleanName,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      profile['createdAt'] = FieldValue.serverTimestamp();
    }

    if (currentApartmentId == null || currentApartmentId.isEmpty) {
      profile['apartmentId'] = aptId;
    }

    await ref.set(profile, SetOptions(merge: true));
  }

  Map<String, dynamic> _memberFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final email = data['email']?.toString() ?? '';
    final name = data['displayName']?.toString().trim();
    final fallbackName = email.split('@').first;

    return {
      'id': doc.id,
      'displayName': name != null && name.isNotEmpty
          ? name
          : fallbackName.isNotEmpty
          ? fallbackName
          : 'Unknown',
      'email': email,
      'apartmentId': data['apartmentId']?.toString() ?? '',
    };
  }

  bool _belongsToApartment(Map<String, dynamic> data, String apartmentId) {
    final value = data['apartmentId']?.toString().trim();
    if (value == null || value.isEmpty) {
      return apartmentId == aptId;
    }
    return value == apartmentId;
  }

  void _sortMembers(List<Map<String, dynamic>> members) {
    members.sort(
      (a, b) => a['displayName'].toString().toLowerCase().compareTo(
        b['displayName'].toString().toLowerCase(),
      ),
    );
  }

  String _displayNameFor({String? email, String? requestedName}) {
    final cleanName = requestedName?.trim();
    if (cleanName != null && cleanName.isNotEmpty) return cleanName;

    final cleanEmail = email?.trim();
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail.split('@').first;
    }

    return 'Unknown';
  }
}
