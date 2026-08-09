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
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            AppWidgets.glowOrb(top: -140, right: -100, size: 360, color: AppColors.violetOrb),
            SafeArea(
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
                          padding: const EdgeInsets.all(20),
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
          backgroundColor: AppColors.surface,
          title: const Text('New Shared Bill', style: AppTextStyles.heading),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Bill Title', labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Total Amount', labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 10),
                const Align(alignment: Alignment.centerLeft, child: Text('Split Between:', style: TextStyle(color: Colors.white70))),
                ...dummyRoommates.map((r) => CheckboxListTile(
                  title: Text(r['name']!, style: const TextStyle(color: Colors.white)),
                  activeColor: AppColors.primary,
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
              child: const Text('Calculate & Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppColors.icon)),
        const Text('Expense Splitter', style: AppTextStyles.heading),
      ],
    ),
  );
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
      padding: const EdgeInsets.only(bottom: 16),
      child: AppWidgets.glassCard(
        padding: const EdgeInsets.all(16.0),
        fillColor: AppColors.glassFillChore,
        borderColor: AppColors.glassBorder,
        boxShadow: const [],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['title'] ?? 'Bill', style: AppTextStyles.heading.copyWith(fontSize: 18)),
                Text('\$${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            ...breakdown.entries.map((entry) {
              final id = entry.key;
              final personData = entry.value as Map;
              final status = personData['status'] ?? 'Pending';
              final isPaid = status == 'Paid';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(personData['name'] ?? 'Unknown', style: AppTextStyles.body),
                    Row(
                      children: [
                        Text('\$${personData['share']}', style: AppTextStyles.body.copyWith(fontSize: 14)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => onToggleStatus(id, status),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPaid ? AppColors.success.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isPaid ? AppColors.success : Colors.orange, width: 1),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isPaid ? AppColors.success : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
