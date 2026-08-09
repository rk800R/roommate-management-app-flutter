import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../crud/expense_crud.dart';
import '../theme/themedata.dart';

class ExpenseSplitterScreen extends StatefulWidget {
  const ExpenseSplitterScreen({super.key});
  @override
  State<ExpenseSplitterScreen> createState() => _ExpenseSplitterScreenState();
}

class _ExpenseSplitterScreenState extends State<ExpenseSplitterScreen> {
  late final ExpenseCrud _crud;
  static const String aptId = 'default_apt';

  @override
  void initState() {
    super.initState();
    _crud = ExpenseCrud(aptId: aptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [AppWidgets.glowOrb(top: -140, right: -100, size: 360, color: AppColors.violetOrb)],
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getExpensesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final expenses = snapshot.data!.docs;
                  
                  if (expenses.isEmpty) {
                    return const Center(child: Text('No expenses logged yet.', style: AppTextStyles.body));
                  }

                  return ListView.builder(
                    padding: AppPadding.pageHorizontal,
                    itemCount: expenses.length,
                    itemBuilder: (context, i) => _ExpenseCard(
                      expense: expenses[i],
                      onToggleStatus: (roommateId, status) =>
                          _crud.toggleSettlementStatus(expenses[i].id, roommateId, status),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final List<Map<String, String>> dummyRoommates = [
      {'id': 'u1', 'name': 'Alice'},
      {'id': 'u2', 'name': 'Bob'},
      {'id': 'u3', 'name': 'Charlie'},
    ];
    final selectedRoommates = <Map<String, String>>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Shared Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Bill Title'),
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Amount'),
                ),
                AppPadding.space12,
                const Align(alignment: Alignment.centerLeft, child: Text('Split Between:', style: AppTextStyles.subtitle)),
                ...dummyRoommates.map((r) => CheckboxListTile(
                  title: Text(r['name']!),
                  value: selectedRoommates.contains(r),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selectedRoommates.add(r);
                      } else {
                        selectedRoommates.remove(r);
                      }
                    });
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (amountCtrl.text.isNotEmpty && selectedRoommates.isNotEmpty) {
                  _crud.addExpense(
                    totalAmount: double.parse(amountCtrl.text),
                    title: titleCtrl.text.isEmpty ? 'Shared Bill' : titleCtrl.text,
                    participants: selectedRoommates,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Calculate & Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => AppWidgets.pageHeader(context, 'Expense Splitter');
}

class _ExpenseCard extends StatelessWidget {
  final QueryDocumentSnapshot expense;
  final void Function(String roommateId, String currentStatus) onToggleStatus;
  const _ExpenseCard({required this.expense, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    final data = expense.data() as Map;
    final breakdown = data['breakdown'] as Map? ?? {};

    return Padding(
      padding: AppPadding.bottom16,
      child: AppWidgets.glassCard(
        padding: AppPadding.tileInner,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['title'] ?? 'Bill', style: AppTextStyles.heading.copyWith(fontSize: 18)),
                Text('\$${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}', style: AppTextStyles.activityAmount.copyWith(color: AppColors.primary, fontSize: 18)),
              ],
            ),
            const Divider(color: AppColors.divider, height: 20),
            ...breakdown.entries.map((entry) {
              final id = entry.key;
              final personData = entry.value as Map;
              final status = personData['status'] ?? 'Pending';
              final isPaid = status == 'Paid';

              return Padding(
                padding: AppPadding.vertical4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(personData['name'] ?? 'Unknown', style: AppTextStyles.body),
                    Row(
                      children: [
                        Text('\$${personData['share']}', style: AppTextStyles.body.copyWith(fontSize: 14)),
                        AppPadding.space12,
                        GestureDetector(
                          onTap: () => onToggleStatus(id, status),
                          child: AppWidgets.statusTag(isPaid),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
