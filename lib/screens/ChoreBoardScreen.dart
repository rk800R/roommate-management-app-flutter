import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../services/DashboardService.dart';
import '../theme/themedata.dart';

/// Screen 3 — The Chore Wheel & Task Board.
///
/// A dedicated screen for assigning, tracking and completing daily apartment
/// chores, with full Firestore CRUD and live sync:
///
///   * **Cloud Firestore CRUD** — add a chore, assign it to a specific
///     roommate, reassign / edit it, mark it **Done**, or delete it. Changes
///     are written to Firestore and re-stream to every device.
///   * **Complex logic & UI** — a dynamic priority badge system
///     (`Urgent` = glowing red, `Normal` = blue) and tappable category filters
///     (Kitchen, Cleaning, Groceries, …) that instantly filter and re-sort.
///   * **The Chore Wheel** — an animated fair-spin wheel that randomly pairs a
///     pending chore with a roommate.
///
/// The board is driven by real-time `StreamBuilder`s on [DashboardService] —
/// there is no manual refresh; Firestore does the syncing.
class ChoreBoardScreen extends StatefulWidget {
  const ChoreBoardScreen({super.key});

  @override
  State<ChoreBoardScreen> createState() => _ChoreBoardScreenState();
}

class _ChoreBoardScreenState extends State<ChoreBoardScreen>
    with TickerProviderStateMixin {
  final DashboardService _dashboard = DashboardService();

  String _categoryFilter = 'All';
  bool _busy = false;

  StreamSubscription<List<Member>>? _membersSub;
  List<Member> _members = const [];

  // ---- Chore Wheel ---------------------------------------------------------
  late final AnimationController _wheelController;
  late final Animation<double> _wheelAnimation;
  double _wheelCurrentAngle = 0;
  bool _wheelSpinning = false;
  _WheelResult? _wheelResult;

  static const List<String> _categories = [
    'All',
    'Kitchen',
    'Bathroom',
    'Living Room',
    'Cleaning',
    'Groceries',
  ];

  @override
  void initState() {
    super.initState();
    _membersSub = _dashboard.membersStream.listen((members) {
      if (mounted) setState(() => _members = members);
    });

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    _wheelController.dispose();
    super.dispose();
  }

  // ---- Helpers -------------------------------------------------------------

  void _toast(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color ?? AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Color _memberColor(int seed) {
    const palette = [
      Color(0xFF7C6BFF),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    return palette[seed % palette.length];
  }

  String _memberInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kitchen':
        return const Color(0xFFF59E0B);
      case 'bathroom':
        return const Color(0xFF3B82F6);
      case 'living room':
        return const Color(0xFFEC4899);
      case 'cleaning':
        return const Color(0xFF22C55E);
      case 'groceries':
        return const Color(0xFF14B8A6);
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'bathroom':
        return Icons.bathtub_rounded;
      case 'living room':
        return Icons.weekend_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'groceries':
        return Icons.shopping_basket_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  String _formatDay(DateTime? date) {
    if (date == null) return 'No date';
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    if (diff > 1 && diff <= 7) return '${diff}d ago';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.day} ${months[day.month - 1]}';
  }

  List<Chore> _applyFilter(List<Chore> chores) {
    var filtered = _categoryFilter == 'All'
        ? List<Chore>.from(chores)
        : chores
            .where((c) => c.category.toLowerCase() == _categoryFilter.toLowerCase())
            .toList();

    // Sort: urgent first, then by due date.
    filtered.sort((a, b) {
      if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
      final aDue = a.dueDate ?? DateTime(2999);
      final bDue = b.dueDate ?? DateTime(2999);
      return aDue.compareTo(bDue);
    });
    return filtered;
  }

  // ---- CRUD actions --------------------------------------------------------

  Future<void> _toggleComplete(Chore chore) async {
    try {
      await _dashboard.setChoreCompleted(chore.id, !chore.completed);
      if (!mounted) return;
      _toast(
        chore.completed ? 'Marked as pending' : 'Marked as done! 🎉',
        color: chore.completed ? AppColors.primary : AppColors.success,
      );
    } catch (_) {
      if (!mounted) return;
      _toast('Could not update chore', color: AppColors.error);
    }
  }

  Future<void> _deleteChore(Chore chore) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientStart,
        title: const Text('Delete chore?'),
        content: Text('“${chore.title}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _dashboard.deleteChore(chore.id);
      if (!mounted) return;
      _toast('Chore deleted', color: AppColors.error);
    } catch (_) {
      if (!mounted) return;
      _toast('Could not delete chore', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showAddChoreSheet({Chore? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChoreFormSheet(
        members: _members,
        chore: editing,
        onSubmit: ({
          required title,
          description,
          required assignedTo,
          required category,
          required priority,
          required points,
          dueDate,
        }) async {
          Navigator.pop(context);
          try {
            if (editing == null) {
              await _dashboard.addChore(
                title: title,
                description: description,
                assignedTo: assignedTo,
                category: category,
                priority: priority,
                points: points,
                dueDate: dueDate,
              );
              _toast('Chore added');
            } else {
              await _dashboard.updateChore(
                id: editing.id,
                title: title,
                description: description,
                assignedTo: assignedTo,
                category: category,
                priority: priority,
                points: points,
                dueDate: dueDate,
              );
              _toast('Chore updated');
            }
          } catch (_) {
            _toast('Something went wrong', color: AppColors.error);
          }
        },
      ),
    );
  }

  // ---- Chore Wheel ---------------------------------------------------------

  Future<void> _spinWheel(List<Chore> pendingChores) async {
    if (_wheelSpinning) return;
    if (pendingChores.isEmpty) {
      _toast('No pending chores to assign!', color: AppColors.error);
      return;
    }
    if (_members.isEmpty) {
      _toast('Add members first!', color: AppColors.error);
      return;
    }

    setState(() {
      _wheelSpinning = true;
      _wheelResult = null;
    });

    final random = math.Random();
    final chosenChore = pendingChores[random.nextInt(pendingChores.length)];
    final chosenMember = _members[random.nextInt(_members.length)];

    // Spin at least 5 full rotations + random offset.
    final spinTurns = 5 + random.nextDouble() * 3;
    final targetAngle = _wheelCurrentAngle + spinTurns * 2 * math.pi;

    _wheelController.reset();
    _wheelAnimation.addListener(() {
      setState(() {
        _wheelCurrentAngle =
            _wheelCurrentAngle + (targetAngle - _wheelCurrentAngle) * 0; // placeholder
      });
    });

    // Animate properly with Tween.
    final tween = Tween<double>(begin: _wheelCurrentAngle, end: targetAngle);
    _wheelAnimation = tween.animate(CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
        setState(() {
          _wheelCurrentAngle = _wheelAnimation.value;
        });
      });

    _wheelController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _wheelSpinning = false;
        _wheelResult = _WheelResult(chore: chosenChore, member: chosenMember);
      });
      _toast(
        '${chosenMember.name} → ${chosenChore.title}',
        color: _memberColor(chosenMember.colorSeed),
      );
    });
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            const _GlowOrb(
              top: -160,
              left: -120,
              size: 420,
              color: AppColors.violetOrb,
            ),
            const _GlowOrb(
              top: -60,
              right: -140,
              size: 360,
              color: AppColors.accentBlue,
            ),
            SafeArea(
              child: StreamBuilder<List<Chore>>(
                stream: _dashboard.allChoresStream,
                builder: (context, snapshot) {
                  final allChores = snapshot.data ?? const <Chore>[];
                  final pending = allChores.where((c) => !c.completed).toList();
                  final completed = allChores.where((c) => c.completed).toList();
                  final filtered = _applyFilter(allChores);

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildHeader(context, pending.length),
                            const SizedBox(height: 20),
                            _ChoreWheelCard(
                              members: _members,
                              pendingChores: pending,
                              currentAngle: _wheelCurrentAngle,
                              spinning: _wheelSpinning,
                              result: _wheelResult,
                              onSpin: () => _spinWheel(pending),
                              memberColor: _memberColor,
                              memberInitials: _memberInitials,
                            ),
                            const SizedBox(height: 24),
                            _buildCategoryFilters(),
                            const SizedBox(height: 16),
                            _buildSectionHeader(
                              'Task Board',
                              '${filtered.where((c) => !c.completed).length} pending · '
                              '${filtered.where((c) => c.completed).length} done',
                            ),
                            const SizedBox(height: 12),
                          ]),
                        ),
                      ),
                      if (!snapshot.hasData)
                        const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (filtered.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 40),
                            child: _GlassCard(
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      color: AppColors.success),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _categoryFilter == 'All'
                                          ? 'No chores yet. Tap + to add the first one!'
                                          : 'No ${_categoryFilter.toLowerCase()} chores.',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final chore = filtered[index];
                              return _ChoreCard(
                                chore: chore,
                                memberColor: _memberColor,
                                memberInitials: _memberInitials,
                                categoryColor: _categoryColor,
                                categoryIcon: _categoryIcon,
                                formatDay: _formatDay,
                                onToggle: () => _toggleComplete(chore),
                                onEdit: () =>
                                    _showAddChoreSheet(editing: chore),
                                onDelete: () => _deleteChore(chore),
                                busy: _busy,
                              );
                            },
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChoreSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Chore',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int pendingCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chore Board',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pendingCount == 0
                    ? 'All caught up — nice!'
                    : '$pendingCount pending ${pendingCount == 1 ? 'chore' : 'chores'}',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_alt_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${_members.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _categoryFilter == cat;
          return GestureDetector(
            onTap: () => setState(() => _categoryFilter = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.accentBlue],
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.10),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chore Wheel
// ---------------------------------------------------------------------------

class _WheelResult {
  const _WheelResult({required this.chore, required this.member});
  final Chore chore;
  final Member member;
}

class _ChoreWheelCard extends StatelessWidget {
  const _ChoreWheelCard({
    required this.members,
    required this.pendingChores,
    required this.currentAngle,
    required this.spinning,
    required this.result,
    required this.onSpin,
    required this.memberColor,
    required this.memberInitials,
  });

  final List<Member> members;
  final List<Chore> pendingChores;
  final double currentAngle;
  final bool spinning;
  final _WheelResult? result;
  final VoidCallback onSpin;
  final Color Function(int) memberColor;
  final String Function(String) memberInitials;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C6BFF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.casino_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chore Wheel',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Spin for a fair random assignment',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _WheelVisual(
            members: members,
            angle: currentAngle,
            spinning: spinning,
            memberColor: memberColor,
            memberInitials: memberInitials,
          ),
          const SizedBox(height: 24),
          if (result != null && !spinning) ...[
            _WheelResultBanner(result: result!, memberColor: memberColor),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentBlue],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: spinning ? null : onSpin,
                  child: Center(
                    child: spinning
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                result != null ? 'Spin Again' : 'Spin the Wheel',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelVisual extends StatelessWidget {
  const _WheelVisual({
    required this.members,
    required this.angle,
    required this.spinning,
    required this.memberColor,
    required this.memberInitials,
  });

  final List<Member> members;
  final double angle;
  final bool spinning;
  final Color Function(int) memberColor;
  final String Function(String) memberInitials;

  @override
  Widget build(BuildContext context) {
    final size = 220.0;
    final memberList = members.isEmpty
        ? [const Member(id: '', name: 'No members', colorSeed: 0)]
        : members;
    final count = memberList.length;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pointer at top
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(24, 16),
              painter: _PointerPainter(),
            ),
          ),
          // The wheel
          Transform.rotate(
            angle: angle,
            child: CustomPaint(
              size: Size.square(size),
              painter: _WheelPainter(
                members: memberList,
                memberColor: memberColor,
              ),
            ),
          ),
          // Center hub
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accentBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: spinning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.members,
    required this.memberColor,
  });

  final List<Member> members;
  final Color Function(int) memberColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final count = members.length;
    final sweep = 2 * math.pi / count;

    for (var i = 0; i < count; i++) {
      final startAngle = i * sweep - math.pi / 2;
      final paint = Paint()
        ..color = memberColor(members[i].colorSeed).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      // Separator line
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        ),
        linePaint,
      );

      // Label
      final labelAngle = startAngle + sweep / 2;
      final labelRadius = radius * 0.65;
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(labelAngle),
        center.dy + labelRadius * math.sin(labelAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: members[i].name.length > 8
              ? '${members[i].name.substring(0, 7)}…'
              : members[i].name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.members != members;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final shadowPath = Path()
      ..moveTo(size.width / 2 + 2, size.height + 2)
      ..lineTo(2, 2)
      ..lineTo(size.width + 2, 2)
      ..close();
    canvas.drawPath(shadowPath, shadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelResultBanner extends StatelessWidget {
  const _WheelResultBanner({
    required this.result,
    required this.memberColor,
  });

  final _WheelResult result;
  final Color Function(int) memberColor;

  @override
  Widget build(BuildContext context) {
    final color = memberColor(result.member.colorSeed);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.20),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                result.member.name.isNotEmpty
                    ? result.member.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.member.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.chore.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.assignment_ind_rounded,
              color: AppColors.textSecondary, size: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chore Card
// ---------------------------------------------------------------------------

class _ChoreCard extends StatelessWidget {
  const _ChoreCard({
    required this.chore,
    required this.memberColor,
    required this.memberInitials,
    required this.categoryColor,
    required this.categoryIcon,
    required this.formatDay,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final Chore chore;
  final Color Function(int) memberColor;
  final String Function(String) memberInitials;
  final Color Function(String) categoryColor;
  final IconData Function(String) categoryIcon;
  final String Function(DateTime?) formatDay;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final catColor = categoryColor(chore.category);
    final isUrgent = chore.isUrgent;

    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox / complete toggle
              GestureDetector(
                onTap: busy ? null : onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chore.completed
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: chore.completed
                          ? AppColors.success
                          : Colors.white.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: chore.completed
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Category icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(categoryIcon(chore.category),
                    color: catColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Title + assigned
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chore.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: chore.completed
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration:
                            chore.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Member avatar dot
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: memberColor(
                              _hashSeed(chore.assignedTo),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              memberInitials(chore.assignedTo),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            chore.assignedTo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Priority badge
              if (isUrgent && !chore.completed)
                _UrgentBadge()
              else if (!chore.completed)
                _NormalBadge(),
            ],
          ),
          if (chore.description != null &&
              chore.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              chore.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              // Due date
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: chore.completed
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatDay(chore.dueDate),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: chore.completed
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (chore.points > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${chore.points} pts',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 15, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              // Delete
              GestureDetector(
                onTap: busy ? null : onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 15, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _hashSeed(String name) {
    var hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0x7FFFFFFF;
    }
    return hash;
  }
}

class _UrgentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFFE5484D), Color(0xFFB91C1C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5484D).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fireplace_rounded, size: 12, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'Urgent',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NormalBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.35),
        ),
      ),
      child: const Text(
        'Normal',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.accentBlue,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit Chore Sheet
// ---------------------------------------------------------------------------

class _ChoreFormSheet extends StatefulWidget {
  const _ChoreFormSheet({
    required this.members,
    required this.chore,
    required this.onSubmit,
  });

  final List<Member> members;
  final Chore? chore;
  final void Function({
    required String title,
    String? description,
    required String assignedTo,
    required String category,
    required String priority,
    required int points,
    DateTime? dueDate,
  }) onSubmit;

  @override
  State<_ChoreFormSheet> createState() => _ChoreFormSheetState();
}

class _ChoreFormSheetState extends State<_ChoreFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;

  String _category = 'Kitchen';
  String _priority = ChorePriority.normal;
  String? _assignedTo;
  DateTime? _dueDate;

  static const _formCategories = [
    'Kitchen',
    'Bathroom',
    'Living Room',
    'Cleaning',
    'Groceries',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.chore;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _pointsCtrl = TextEditingController(text: c != null && c.points > 0 ? '${c.points}' : '');
    _category = c?.category ?? 'Kitchen';
    _priority = c?.priority ?? ChorePriority.normal;
    _assignedTo = c?.assignedTo ??
        (widget.members.isNotEmpty ? widget.members.first.name : 'Unassigned');
    _dueDate = c?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.gradientStart,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a chore title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_assignedTo == null || _assignedTo!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign the chore to someone'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final points = int.tryParse(_pointsCtrl.text.trim()) ?? 0;

    widget.onSubmit(
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      assignedTo: _assignedTo!,
      category: _category,
      priority: _priority,
      points: points,
      dueDate: _dueDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chore != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gradientStart,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEditing ? 'Edit Chore' : 'New Chore',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel('Title'),
            _buildTextField(
              controller: _titleCtrl,
              hint: 'e.g. Wash the dishes',
              icon: Icons.task_alt_rounded,
            ),
            const SizedBox(height: 16),
            _buildLabel('Description (optional)'),
            _buildTextField(
              controller: _descCtrl,
              hint: 'Add details…',
              icon: Icons.description_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildLabel('Assign to'),
            _buildMemberPicker(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabel('Category')),
                const SizedBox(width: 16),
                Expanded(child: _buildLabel('Priority')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildPriorityDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabel('Points')),
                const SizedBox(width: 16),
                Expanded(child: _buildLabel('Due date')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _pointsCtrl,
                    hint: '0',
                    icon: Icons.stars_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePicker()),
              ],
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: AppColors.icon, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberPicker() {
    if (widget.members.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: const Text(
          'No members available',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final m = widget.members[index];
          final isSelected = _assignedTo == m.name;
          final color = _memberColorForPicker(m.colorSeed);
          return GestureDetector(
            onTap: () => setState(() => _assignedTo = m.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        m.name.isNotEmpty
                            ? m.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _memberColorForPicker(int seed) {
    const palette = [
      Color(0xFF7C6BFF),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    return palette[seed % palette.length];
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          dropdownColor: AppColors.gradientStart,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.icon, size: 20),
          isExpanded: true,
          items: _formCategories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _priority,
          dropdownColor: AppColors.gradientStart,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.icon, size: 20),
          isExpanded: true,
          items: ChorePriority.values
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Icon(
                          p == ChorePriority.urgent
                              ? Icons.fireplace_rounded
                              : Icons.circle,
                          size: 14,
                          color: p == ChorePriority.urgent
                              ? const Color(0xFFE5484D)
                              : AppColors.accentBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(p),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _priority = v ?? _priority),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: AppColors.icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _dueDate == null
                    ? 'Pick a date'
                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _dueDate == null
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (_dueDate != null)
              GestureDetector(
                onTap: () => setState(() => _dueDate = null),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accentBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _submit,
            child: Center(
              child: Text(
                isEditing ? 'Save Changes' : 'Add Chore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared presentational helpers
// ---------------------------------------------------------------------------

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}