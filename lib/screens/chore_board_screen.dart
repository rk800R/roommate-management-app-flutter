import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../crud/chore_crud.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
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
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb)],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, 'Chore Board', showBack: true),
            _buildFilters(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getChoresStream(_categoryFilter),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chores = snapshot.data!.docs;
                  if (chores.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.checklist_rounded, size: 64, color: AppColors.icon),
                          AppPadding.space12,
                          Text('No chores yet', style: AppTextStyles.emptyState),
                        ],
                      ),
                    );
                  }

                  // Sort: incomplete first, then urgent first
                  chores.sort((a, b) {
                    final aData = a.data() as Map;
                    final bData = b.data() as Map;
                    int doneCompare = (aData['isDone'] == true ? 1 : 0)
                        .compareTo(bData['isDone'] == true ? 1 : 0);
                    if (doneCompare != 0) return doneCompare;
                    return (bData['priority'] == 'Urgent' ? 1 : 0)
                        .compareTo(aData['priority'] == 'Urgent' ? 1 : 0);
                  });

                  return ListView.builder(
                    padding: AppPadding.pageList,
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
                        onToggle: (val) =>
                            _crud.toggleChoreStatus(chores[i].id, val ?? false),
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
        onPressed: () => _showAddChoreDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddChoreDialog(BuildContext context) async {
    final titleController = TextEditingController();
    String category = 'Kitchen';
    String priority = 'Normal';
    final service = AppService();

    // Load the real apartment members (stored in Firestore) once, before
    // showing the dialog, so tasks can only be assigned to current members.
    List<Map<String, dynamic>> members;
    try {
      members = await service.getMembers(aptId);
    } catch (_) {
      members = [];
    }
    // Selected member as {id, displayName}; null = Unassigned.
    Map<String, dynamic>? selectedMember;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Chore'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Chore Title'),
                ),
                AppPadding.space12,
                if (members.isEmpty)
                  Text('No members in this apartment yet.',
                      style: AppTextStyles.subtitle)
                else
                  DropdownButton<String>(
                    value: selectedMember == null
                        ? '__unassigned__'
                        : selectedMember!['id'].toString(),
                    isExpanded: true,
                    hint: const Text('Assign to'),
                    items: [
                      const DropdownMenuItem(
                        value: '__unassigned__',
                        child: Text('Unassigned'),
                      ),
                      ...members.map((m) => DropdownMenuItem(
                            value: m['id'].toString(),
                            child: Text(m['displayName'].toString()),
                          )),
                    ],
                    onChanged: (v) => setState(() {
                      selectedMember = (v == null || v == '__unassigned__')
                          ? null
                          : members.firstWhere((m) => m['id'].toString() == v);
                    }),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _crud.addChore(
                    title: titleController.text,
                    assignedTo: selectedMember?['displayName']?.toString() ?? 'Unassigned',
                    assignedToId: selectedMember?['id']?.toString(),
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

  Widget _buildFilters() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          children: ['All', 'Kitchen', 'Cleaning', 'Groceries']
              .map((c) => Padding(
                    padding: AppPadding.right8,
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _categoryFilter == c ||
                          (_categoryFilter == null && c == 'All'),
                      onSelected: (s) =>
                          setState(() => _categoryFilter = c == 'All' ? null : c),
                    ),
                  ))
              .toList(),
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
        child: Row(
          children: [
            Checkbox(value: isDone, onChanged: onToggle),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Untitled',
                    style: isDone ? AppTextStyles.choreTitleCompleted : AppTextStyles.choreTitle,
                  ),
                  if (data['assignedTo'] != null &&
                      data['assignedTo'].toString().isNotEmpty)
                    Text(
                      'Assigned to: ${data['assignedTo']}',
                      style: AppTextStyles.choreSubtitle,
                    ),
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