import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../crud/chore_crud.dart';
import '../theme/themedata.dart';

class ChoreBoardScreen extends StatefulWidget {
  const ChoreBoardScreen({super.key});
  @override
  State<ChoreBoardScreen> createState() => _ChoreBoardScreenState();
}

class _ChoreBoardScreenState extends State<ChoreBoardScreen> {
  late final ChoreCrud _crud;
  String? _categoryFilter;
  static const String aptId = 'default_apt';

  @override
  void initState() {
    super.initState();
    _crud = ChoreCrud(aptId: aptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _crud.getChoresStream(_categoryFilter),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        final chores = snapshot.data!.docs;
                        // Instantly resort: Incomplete first, then Urgent priority first
                        chores.sort((a, b) {
                          final aData = a.data() as Map;
                          final bData = b.data() as Map;
                          
                          int doneCompare = (aData['isDone'] == true ? 1 : 0).compareTo(bData['isDone'] == true ? 1 : 0);
                          if (doneCompare != 0) return doneCompare;
                          
                          return (bData['priority'] == 'Urgent' ? 1 : 0).compareTo(aData['priority'] == 'Urgent' ? 1 : 0);
                        });
                        
                        return ListView.builder(
                          padding: AppPadding.pageHorizontal,
                          itemCount: chores.length,
                          itemBuilder: (context, i) => Dismissible(
                            key: ValueKey(chores[i].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: AppPadding.pageHorizontal,
                              margin: AppPadding.bottom12,
                              decoration: AppDecorations.dismissibleBackground(),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _crud.deleteChore(chores[i].id),
                            child: _ChoreTile(
                              chore: chores[i],
                              onToggle: (val) => _crud.toggleChoreStatus(chores[i].id, val ?? false),
                            ),
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
        onPressed: () => _showAddChoreDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddChoreDialog(BuildContext context) {
    final titleController = TextEditingController();
    final assigneeController = TextEditingController();
    String category = 'Kitchen';
    String priority = 'Normal';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Chore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Chore Title'),
              ),
              TextField(
                controller: assigneeController,
                decoration: const InputDecoration(labelText: 'Assign to (Roommate)'),
              ),
              AppPadding.space12,
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ['Kitchen', 'Cleaning', 'Groceries']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v ?? 'Kitchen'),
              ),
              DropdownButton<String>(
                value: priority,
                isExpanded: true,
                items: ['Normal', 'Urgent']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => priority = v ?? 'Normal'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _crud.addChore(
                    title: titleController.text,
                    assignedTo: assigneeController.text,
                    category: category,
                    priority: priority,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => AppWidgets.pageHeader(context, 'Chore Board');

  Widget _buildFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: AppPadding.pageHorizontal,
    child: Row(
      children: ['All', 'Kitchen', 'Cleaning', 'Groceries'].map((c) => Padding(
        padding: AppPadding.right8,
        child: ChoiceChip(
          label: Text(c),
          selected: _categoryFilter == c || (_categoryFilter == null && c == 'All'),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(color: (_categoryFilter == c || (_categoryFilter == null && c == 'All')) ? Colors.white : AppColors.icon),
          onSelected: (s) => setState(() => _categoryFilter = c == 'All' ? null : c),
        ),
      )).toList(),
    ),
  );
}

class _ChoreTile extends StatelessWidget {
  final QueryDocumentSnapshot chore;
  final ValueChanged<bool?> onToggle;
  const _ChoreTile({required this.chore, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final data = chore.data() as Map;
    final isDone = data['isDone'] == true;
    final priority = data['priority'] as String? ?? 'Normal';

    return Padding(
      padding: AppPadding.bottom12,
      child: AppWidgets.glassCard(
        padding: AppPadding.tileInner,
        fillColor: AppColors.glassFillChore,
        borderColor: AppColors.glassBorder,
        boxShadow: const [],
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: onToggle,
              activeColor: AppColors.success,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'] ?? 'Untitled', style: isDone ? AppTextStyles.choreTitleCompleted : AppTextStyles.choreTitle),
                  if (data['assignedTo'] != null && data['assignedTo'].toString().isNotEmpty)
                    Text('Assigned to: ${data['assignedTo']}', style: AppTextStyles.choreSubtitle),
                ],
              ),
            ),
            AppWidgets.priorityBadge(priority),
          ],
        ),
      ),
    );
  }
}
