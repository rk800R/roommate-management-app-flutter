import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../crud/expense_crud.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
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
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(
            top: -140,
            right: -100,
            size: 360,
            color: AppColors.violetOrb,
          ),
        ],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, 'Expense Splitter', showBack: true),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getExpensesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final expenses = snapshot.data!.docs;
                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 64,
                            color: AppColors.icon,
                          ),
                          AppPadding.space12,
                          Text(
                            'No expenses logged yet',
                            style: AppTextStyles.emptyState,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: AppPadding.pageList,
                    itemCount: expenses.length,
                    itemBuilder: (context, i) => _ExpenseCard(
                      expense: expenses[i],
                      onToggleStatus: (roommateId, status) =>
                          _crud.toggleSettlementStatus(
                            expenses[i].id,
                            roommateId,
                            status,
                          ),
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

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final service = AppService();

    // Use the real apartment members stored in Firestore for the split.
    List<Map<String, dynamic>> members;
    try {
      members = await service.getMembers(aptId);
    } catch (_) {
      members = [];
    }
    final selectedRoommates = <Map<String, String>>[];

    if (!context.mounted) return;
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Split Between:', style: AppTextStyles.subtitle),
                ),
                if (members.isEmpty)
                  Padding(
                    padding: AppPadding.top8,
                    child: Text(
                      'No members in this apartment yet.',
                      style: AppTextStyles.subtitle,
                    ),
                  )
                else
                  ...members.map(
                    (m) => CheckboxListTile(
                      title: Text(m['displayName'].toString()),
                      value: selectedRoommates.any((r) => r['id'] == m['id']),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedRoommates.add({
                              'id': m['id'].toString(),
                              'name': m['displayName'].toString(),
                            });
                          } else {
                            selectedRoommates.removeWhere(
                              (r) => r['id'] == m['id'],
                            );
                          }
                        });
                      },
                    ),
                  ),
                if (selectedRoommates.isNotEmpty && amountCtrl.text.isNotEmpty)
                  Padding(
                    padding: AppPadding.top8,
                    child: Text(
                      'Each pays: PKR ${(double.tryParse(amountCtrl.text) ?? 0) / selectedRoommates.length}',
                      style: AppTextStyles.activityAmount,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (amountCtrl.text.isNotEmpty &&
                    selectedRoommates.isNotEmpty) {
                  _crud.addExpense(
                    totalAmount: double.parse(amountCtrl.text),
                    title: titleCtrl.text.isEmpty
                        ? 'Shared Bill'
                        : titleCtrl.text,
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
                Expanded(
                  child: Text(
                    data['title'] ?? 'Bill',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                  ),
                ),
                AppPadding.width12,
                Text(
                  'PKR ${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: AppTextStyles.activityAmount.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.divider, height: 20),
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
                    Expanded(
                      child: Text(
                        personData['name'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body,
                      ),
                    ),
                    AppPadding.width12,
                    Row(
                      children: [
                        Text(
                          'PKR ${personData['share']}',
                          style: AppTextStyles.body.copyWith(fontSize: 14),
                        ),
                        AppPadding.width12,
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
