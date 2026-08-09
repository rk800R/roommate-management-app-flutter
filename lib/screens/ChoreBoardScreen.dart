import 'dart:async';

import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../services/DashboardService.dart';
import '../theme/styling/appstyling.dart';
import 'LoginScreen.dart';




class ChoreBoardScreen extends StatefulWidget {
  const ChoreBoardScreen({super.key});

  @override
  State<ChoreBoardScreen> createState() => _ChoreBoardScreenState();
}

class _ChoreBoardScreenState extends State<ChoreBoardScreen> {
  final AuthService _authService = AuthService();
  final DashboardService _dashboard = DashboardService();
  bool _isSaving = false;
  ChoreFilter _filter = ChoreFilter.pending;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');
  String _assignedTo = '';
  String _category = 'General';
  String _priority = ChorePriority.normal;
  DateTime? _dueDate;
  List<Member> _members = const <Member>[];

  @override
  void initState() {
    super.initState();
    _dashboard.membersStream.listen((members) {
      if (mounted) setState(() => _members = members);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.gradientStart,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.gradientStart),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submitChore() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final description = _descriptionController.text.trim();
      final points = int.tryParse(_pointsController.text.trim()) ?? 0;
      await _dashboard.addChore(
        title: title,
        description: description.isEmpty ? null : description,
        assignedTo: _assignedTo.isEmpty ? 'Unassigned' : _assignedTo,
        category: _category,
        priority: _priority,
        points: points,
        dueDate: _dueDate,
      );
      if (mounted) {
        _resetForm();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chore added!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _pointsController.text = '0';
    _assignedTo = '';
    _category = 'General';
    _priority = ChorePriority.normal;
    _dueDate = null;
  }

  void _showAddChoreSheet(List<Member> members) {
    if (members.isNotEmpty) {
      _assignedTo = _assignedTo.isEmpty ? members.first.name : _assignedTo;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.gradientStart,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'New Chore',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Title',
                      hint: 'e.g. Take out the trash',
                      controller: _titleController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      label: 'Description',
                      hint: 'Any details...',
                      controller: _descriptionController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    if (members.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: _assignedTo.isEmpty ? members.first.name : _assignedTo,
                        decoration: _inputDecor('Assigned to'),
                        items: members
                            .map((m) => DropdownMenuItem(value: m.name, child: Text(m.name)))
                            .toList(),
                        onChanged: (v) => setModalState(() => _assignedTo = v ?? ''),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: _inputDecor('Category'),
                            items: const [
                              DropdownMenuItem(value: 'General', child: Text('General')),
                              DropdownMenuItem(value: 'Kitchen', child: Text('Kitchen')),
                              DropdownMenuItem(value: 'Bathroom', child: Text('Bathroom')),
                              DropdownMenuItem(value: 'Living Room', child: Text('Living Room')),
                              DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                              DropdownMenuItem(value: 'Groceries', child: Text('Groceries')),
                            ],
                            onChanged: (v) => setModalState(() => _category = v ?? 'General'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: _inputDecor('Priority'),
                            items: const [
                              DropdownMenuItem(value: ChorePriority.normal, child: Text('Normal')),
                              DropdownMenuItem(value: ChorePriority.urgent, child: Text('Urgent')),
                            ],
                            onChanged: (v) => setModalState(() => _priority = v ?? ChorePriority.normal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecor('Points').copyWith(hintText: '0'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: _inputDecor('Due date'),
                              child: Text(
                                _dueDate == null
                                    ? 'Pick a date'
                                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                                style: TextStyle(
                                  color: _dueDate == null ? AppColors.textMuted : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitChore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Add Chore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildField({required String label, required String hint, required TextEditingController controller, int maxLines = 1, bool isRequired = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecor(label).copyWith(hintText: hint),
      style: const TextStyle(color: AppColors.textPrimary),
    );
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
            AppWidgets.glowOrb(top: -60, right: -120, size: 320, color: AppColors.accentBlue),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.icon),
                        ),
                        const Expanded(
                          child: Text(
                            'Chore Board',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textPrimary),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Log out',
                          icon: const Icon(Icons.logout_rounded, color: AppColors.icon),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.gradientStart,
                                title: const Text('Log out'),
                                content: const Text('Are you sure you want to log out?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final nav = Navigator.of(context);
                              final isMounted = mounted;
                              await _authService.signOut();
                              if (!isMounted) return;
                              nav.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _FilterChip(label: 'Pending', selected: _filter == ChoreFilter.pending, onTap: () => setState(() => _filter = ChoreFilter.pending)),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Completed', selected: _filter == ChoreFilter.completed, onTap: () => setState(() => _filter = ChoreFilter.completed)),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'All', selected: _filter == ChoreFilter.all, onTap: () => setState(() => _filter = ChoreFilter.all)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<List<Chore>>(
                      stream: _dashboard.allChoresStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary));
                        }
                        var chores = snapshot.data!;
                        switch (_filter) {
                          case ChoreFilter.pending:
                            chores = chores.where((c) => !c.completed).toList();
                            break;
                          case ChoreFilter.completed:
                            chores = chores.where((c) => c.completed).toList();
                            break;
                          case ChoreFilter.all:
                            break;
                        }
                        chores.sort((a, b) {
                          if (a.completed != b.completed) return a.completed ? 1 : -1;
                          final da = a.dueDate ?? DateTime.now();
                          final db = b.dueDate ?? DateTime.now();
                          return da.compareTo(db);
                        });
                        if (chores.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _filter == ChoreFilter.all ? 'No chores yet. Tap + to add one.' : 'No ${_filter == ChoreFilter.pending ? "pending" : "completed"} chores.',
                                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                          itemCount: chores.length,
                          itemBuilder: (context, index) {
                            final chore = chores[index];
                            return ChoreBoardTile(
                              chore: chore,
                              onToggle: () => _dashboard.setChoreCompleted(chore.id, !chore.completed),
                              onDelete: () => _dashboard.deleteChore(chore.id),
                              onEdit: () => _showEditChoreSheet(chore, members: _members),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: StreamBuilder<List<Member>>(
                stream: _dashboard.membersStream,
                builder: (context, memberSnap) {
                  return FloatingActionButton.extended(
                    onPressed: () => _showAddChoreSheet(_members),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                    label: const Text('Add chore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditChoreSheet(Chore chore, {required List<Member> members}) {
    _titleController.text = chore.title;
    _descriptionController.text = chore.description ?? '';
    _pointsController.text = chore.points.toString();
    _assignedTo = chore.assignedTo;
    _category = chore.category;
    _priority = chore.priority;
    _dueDate = chore.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: const BoxDecoration(color: AppColors.gradientStart, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  shrinkWrap: true,
                  children: [
                    const Text('Edit Chore', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    const SizedBox(height: 20),
                    _buildField(label: 'Title', hint: 'Chore title', controller: _titleController, isRequired: true),
                    const SizedBox(height: 14),
                    _buildField(label: 'Description', hint: 'Details...', controller: _descriptionController, maxLines: 2),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _assignedTo.isEmpty ? 'Unassigned' : _assignedTo,
                      decoration: _inputDecor('Assigned to'),
                      items: [
                        const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned')),
                        ..._members.map((m) => DropdownMenuItem(value: m.name, child: Text(m.name))),
                      ],
                      onChanged: (v) => setModalState(() => _assignedTo = v ?? ''),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: _inputDecor('Category'),
                            items: const [
                              DropdownMenuItem(value: 'General', child: Text('General')),
                              DropdownMenuItem(value: 'Kitchen', child: Text('Kitchen')),
                              DropdownMenuItem(value: 'Bathroom', child: Text('Bathroom')),
                              DropdownMenuItem(value: 'Living Room', child: Text('Living Room')),
                              DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                              DropdownMenuItem(value: 'Groceries', child: Text('Groceries')),
                            ],
                            onChanged: (v) => setModalState(() => _category = v ?? 'General'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: _inputDecor('Priority'),
                            items: const [
                              DropdownMenuItem(value: ChorePriority.normal, child: Text('Normal')),
                              DropdownMenuItem(value: ChorePriority.urgent, child: Text('Urgent')),
                            ],
                            onChanged: (v) => setModalState(() => _priority = v ?? ChorePriority.normal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecor('Points').copyWith(hintText: '0'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? now,
                                firstDate: now.subtract(const Duration(days: 1)),
                                lastDate: now.add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.gradientStart),
                                      dialogTheme: const DialogThemeData(backgroundColor: AppColors.gradientStart),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null && mounted) {
                                setModalState(() => _dueDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: _inputDecor('Due date'),
                              child: Text(
                                _dueDate == null ? 'Pick a date' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                                style: TextStyle(color: _dueDate == null ? AppColors.textMuted : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () async {
                          final title = _titleController.text.trim();
                          if (title.isEmpty) return;
                          setState(() => _isSaving = true);
                          final isMounted = mounted;
                          try {
                            final desc = _descriptionController.text.trim();
                            final pts = int.tryParse(_pointsController.text.trim()) ?? 0;
                            final nav = Navigator.of(context);
                            final snack = ScaffoldMessenger.of(context);
                            await _dashboard.updateChore(
                              id: chore.id,
                              title: title,
                              description: desc.isEmpty ? null : desc,
                              assignedTo: _assignedTo.isEmpty ? 'Unassigned' : _assignedTo,
                              category: _category,
                              priority: _priority,
                              points: pts,
                              dueDate: _dueDate,
                            );
                            if (isMounted) {
                              _resetForm();
                              nav.pop();
                              snack.showSnackBar(
                                const SnackBar(content: Text('Chore updated.'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary, duration: Duration(seconds: 1)),
                              );
                            }
                          } catch (_) {
                            if (isMounted) {
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Update failed. Try again.'),
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.error,
    duration: Duration(seconds: 2),
  ),
);
                            }
                          } finally {
                            if (isMounted) setState(() => _isSaving = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: _isSaving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ChoreFilter { pending, completed, all }

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class ChoreBoardTile extends StatelessWidget {
  const ChoreBoardTile({super.key, required this.chore, required this.onToggle, required this.onDelete, required this.onEdit});
  final Chore chore;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kitchen': return const Color(0xFFF59E0B);
      case 'bathroom': return const Color(0xFF3B82F6);
      case 'living room': return const Color(0xFFEC4899);
      case 'cleaning':
      case 'chore': return const Color(0xFF22C55E);
      default: return AppColors.primary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${day.day} ${months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(chore.category);
    final isUrgent = chore.priority.toLowerCase() == ChorePriority.urgent.toLowerCase();

    return Dismissible(
      key: ValueKey(chore.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(AppRadii.card)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onLongPress: onEdit,
        child: AppWidgets.glassCard(
          padding: AppPadding.tileInner,
          fillColor: AppColorsExtended.glassFillChore,
          borderColor: AppColorsExtended.glassBorder,
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: AppDecorations.toggleCircle(completed: chore.completed, color: AppColors.success),
                  child: chore.completed ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                ),
              ),
              AppPadding.space12,
              Container(
                width: 42,
                height: 42,
                decoration: AppDecorations.tileIcon(color: color, active: !chore.completed),
                child: Icon(Icons.cleaning_services_rounded, color: chore.completed ? AppColors.textMuted : color, size: 20),
              ),
              AppPadding.space12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chore.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: chore.completed ? AppTextStylesExtended.choreTitleCompleted : AppTextStylesExtended.choreTitle),
                    const SizedBox(height: 3),
                    Text('${chore.assignedTo} \u00b7 ${chore.category}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: chore.completed ? AppTextStylesExtended.choreSubtitleCompleted : AppTextStylesExtended.choreSubtitle),
                  ],
                ),
              ),
              AppPadding.space8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chore.points > 0 && !chore.completed)
                    Text('+${chore.points} pts', style: AppTextStylesExtended.chorePoints),
                  if (isUrgent && !chore.completed) ...[
                    AppPadding.space4,
                    Container(
                      padding: AppPadding.badge,
                      decoration: AppDecorations.urgentBadge(),
                      child: Text('Urgent', style: AppTextStylesExtended.urgentBadge),
                    ),
                  ],
                  AppPadding.space4,
                  Text(_formatDate(chore.dueDate),
                    style: chore.completed ? AppTextStylesExtended.choreDateCompleted : AppTextStylesExtended.choreDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}







