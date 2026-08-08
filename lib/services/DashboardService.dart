import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Names of the Firestore collections the dashboard listens to.
///
/// Keep these in sync with the collections you create in the Firebase
/// console (`internship-2026-roommate-app`).
abstract final class FirestoreCollections {
  static const String chores = 'chores';
  static const String members = 'members';
  static const String payments = 'payments';
  static const String expenses = 'expenses';
}

/// Formatting / currency helper.
///
/// Update [currencySymbol] to match this app's currency (Icelandic króna by
/// default given the project context). Whole numbers are shown without decimals.
abstract final class AppCurrency {
  static const String symbol = 'PKR';

  static String money(num value) => '$symbol${value.toStringAsFixed(0)}';
}

/// A single house chore read from Firestore.
class Chore {
  const Chore({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    this.category = 'General',
    this.priority = 'Normal',
    this.points = 0,
    required this.completed,
    this.dueDate,
  });

  final String id;
  final String title;
  final String? description;
  final String assignedTo;

  /// Which area of the house this belongs to (Kitchen, Cleaning, Groceries…).
  final String category;

  /// Priority tier — `'Urgent'` or `'Normal'`. Drives the glowing badge.
  final String priority;
  final int points;
  final bool completed;
  final DateTime? dueDate;

  /// Whether this chore is flagged as [ChorePriority.urgent].
  bool get isUrgent =>
      priority.toLowerCase() == ChorePriority.urgent.toLowerCase();

  factory Chore.fromDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    final due = data['dueDate'];
    return Chore(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Untitled chore',
      description: data['description'] as String?,
      assignedTo: (data['assignedTo'] as String?) ?? 'Unassigned',
      category: (data['category'] as String?) ?? 'General',
      priority: (data['priority'] as String?) ?? 'Normal',
      points: (data['points'] as num?)?.toInt() ?? 0,
      completed: (data['completed'] as bool?) ?? false,
      dueDate: due is Timestamp ? due.toDate() : null,
    );
  }
}

/// Supported values for [Chore.priority].
abstract final class ChorePriority {
  static const String urgent = 'Urgent';
  static const String normal = 'Normal';

  /// The two tiers, in the order they should be offered in pickers.
  static const List<String> values = [urgent, normal];
}

/// A roommate / household member.
class Member {
  const Member({
    required this.id,
    required this.name,
    this.monthlyDue = 0,
    this.colorSeed = 0,
  });

  final String id;
  final String name;
  final double monthlyDue;

  /// Seed for deriving a stable avatar color per member.
  final int colorSeed;

  factory Member.fromDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return Member(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Member',
      monthlyDue: (data['monthlyDue'] as num?)?.toDouble() ?? 0,
      colorSeed: (data['colorSeed'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A rent / shared-dues payment recorded by a member.
class Payment {
  const Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    this.note,
    this.date,
  });

  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String? note;
  final DateTime? date;

  factory Payment.fromDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    final date = data['date'];
    return Payment(
      id: doc.id,
      memberId: (data['memberId'] as String?) ?? '',
      memberName: (data['memberName'] as String?) ?? 'Member',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      note: data['note'] as String?,
      date: date is Timestamp ? date.toDate() : null,
    );
  }
}

/// A shared household expense.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    this.category = 'General',
    this.date,
  });

  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final String category;
  final DateTime? date;

  factory Expense.fromDoc(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    final date = data['date'];
    return Expense(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paidBy: (data['paidBy'] as String?) ?? 'Member',
      category: (data['category'] as String?) ?? 'General',
      date: date is Timestamp ? date.toDate() : null,
    );
  }
}

/// Live aggregate of household dues: what every member owes this month
/// versus what has actually been paid.
class DuesSummary {
  const DuesSummary({
    required this.totalMonthlyDue,
    required this.totalPaid,
    this.paymentCount = 0,
  });

  final double totalMonthlyDue;
  final double totalPaid;
  final int paymentCount;

  /// Outstanding balance owed by the household.
  double get remaining =>
      (totalMonthlyDue - totalPaid).clamp(0.0, double.infinity);

  /// Fraction of dues settled so far, clamped to [0, 1].
  double get progress =>
      totalMonthlyDue <= 0 ? 0 : (totalPaid / totalMonthlyDue).clamp(0.0, 1.0);
}


/// Wraps Cloud Firestore reads for the dashboard.
///
/// Mirrors the `AuthService` pattern: screens never talk to
/// `FirebaseFirestore.instance` directly. Every getter returns a real-time
/// `Stream` so the UI can stay live with `StreamBuilder`.
class DashboardService {
  DashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Query<Object?> _collection(String name) => _firestore.collection(name);

  /// Real-time stream of **pending** (not yet completed) chores, soonest due
  /// first. Sorted server-side by `dueDate` only, with the completion filter
  /// applied in Dart so no composite Firestore index is required.
  Stream<List<Chore>> get pendingChoresStream =>
      _collection(FirestoreCollections.chores)
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map(Chore.fromDoc)
                .where((c) => !c.completed)
                .take(8)
                .toList(),
          );

  /// Real-time stream of all chores (used for progress / today calculations).
  Stream<List<Chore>> get allChoresStream =>
      _collection(FirestoreCollections.chores)
          .snapshots()
          .map((snap) => snap.docs.map(Chore.fromDoc).toList());

  /// Real-time stream of household members.
  Stream<List<Member>> get membersStream =>
      _collection(FirestoreCollections.members).snapshots().map(
            (snap) => snap.docs.map(Member.fromDoc).toList(),
          );

  /// Real-time stream of recorded payments, newest first.
  Stream<List<Payment>> get paymentsStream =>
      _collection(FirestoreCollections.payments)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(Payment.fromDoc).toList());

  /// Real-time stream of household expenses, newest first.
  Stream<List<Expense>> get expensesStream =>
      _collection(FirestoreCollections.expenses)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(Expense.fromDoc).toList());

  /// Real-time combined dues summary built from the members and payments
  /// streams. Re-emits whenever either collection changes.
  Stream<DuesSummary> get duesSummary => combineLatest(
        membersStream,
        paymentsStream,
        (members, payments) {
          final totalDue = members.fold<double>(
            0,
            (acc, m) => acc + m.monthlyDue,
          );
          final paid = payments.fold<double>(0, (acc, p) => acc + p.amount);
          return DuesSummary(
            totalMonthlyDue: totalDue,
            totalPaid: paid,
            paymentCount: payments.length,
          );
        },
      );
  }

  // ---- Chore writes (CRUD) --------------------------------------------------

  /// Creates a new chore in Firestore and returns its generated document id.
  Future<String> addChore({
    required String title,
    String? description,
    required String assignedTo,
    String category = 'General',
    String priority = ChorePriority.normal,
    int points = 0,
    DateTime? dueDate,
  }) async {
    final doc = await _collection(FirestoreCollections.chores).add({
      'title': title.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'assignedTo': assignedTo,
      'category': category,
      'priority': priority,
      'points': points,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
    });
    return doc.id;
  }

  /// Marks a chore done / undone in Firestore (live-syncs to every device).
  Future<void> setChoreCompleted(String id, bool completed) => _collection(
        FirestoreCollections.chores,
      ).doc(id).update({'completed': completed});

  /// Updates the mutable fields of an existing chore. Only non-`null` values
  /// are written, so partial updates (e.g. just re-assigning) are safe.
  Future<void> updateChore({
    required String id,
    String? title,
    String? assignedTo,
    String? category,
    String? priority,
    int? points,
    DateTime? dueDate,
  }) async {
    final data = <String, dynamic>{
      if (title != null) 'title': title.trim(),
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (points != null) 'points': points,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
    };
    await _collection(FirestoreCollections.chores).doc(id).update(data);
  }

  /// Permanently removes a chore from Firestore.
  Future<void> deleteChore(String id) =>
      _collection(FirestoreCollections.chores).doc(id).delete();
}

/// Merges the two latest values of [a] and [b] into a single stream via
/// [combine], re-emitting whenever either source changes.
///
/// A small standalone stand-in for `Rx.combineLatest2` (no dependency needed).
Stream<T> combineLatest<A, B, T>(
  Stream<A> a,
  Stream<B> b,
  T Function(A a, B b) combine,
) {
  A? latestA;
  B? latestB;
  var aReady = false;
  var bReady = false;

  final controller = StreamController<T>.broadcast();

  void tryEmit() {
    if (aReady && bReady) {
      controller.add(combine(latestA as A, latestB as B));
    }
  }

  final subA = a.listen(
    (v) {
      latestA = v;
      aReady = true;
      tryEmit();
    },
    onError: controller.addError,
    onDone: () {
      if (bReady) controller.close();
    },
  );

  final subB = b.listen(
    (v) {
      latestB = v;
      bReady = true;
      tryEmit();
    },
    onError: controller.addError,
    onDone: () {
      if (aReady) controller.close();
    },
  );

  controller.onCancel = () {
    subA.cancel();
    subB.cancel();
  };

  return controller.stream;
}

