import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseCrud {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String aptId;

  ExpenseCrud({required this.aptId});

  CollectionReference get _expensesRef =>
      _db.collection('apartments').doc(aptId).collection('expenses');

  // READ
  Stream<QuerySnapshot> getExpensesStream() {
    return _expensesRef.orderBy('createdAt', descending: true).snapshots();
  }

  // CREATE: Algorithmic Split
  Future<void> addExpense({
    required double totalAmount,
    required String title,
    required List<Map<String, String>> participants,
  }) async {
    final double individualShare = totalAmount / participants.length;
    
    Map<String, dynamic> breakdown = {};
    for (var p in participants) {
      breakdown[p['id']!] = {
        'name': p['name'],
        'share': individualShare.toStringAsFixed(2),
        'status': 'Pending',
      };
    }

    await _expensesRef.add({
      'title': title,
      'totalAmount': totalAmount,
      'splitCount': participants.length,
      'breakdown': breakdown,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: Toggle Settlement Status
  Future<void> toggleSettlementStatus(String expenseId, String roommateId, String currentStatus) {
    String newStatus = currentStatus == 'Pending' ? 'Paid' : 'Pending';
    return _expensesRef.doc(expenseId).update({
      'breakdown.$roommateId.status': newStatus,
    });
  }
}
