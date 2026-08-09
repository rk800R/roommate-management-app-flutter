import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../services/DashboardService.dart';
import '../theme/styling/appstyling.dart';
import 'ChoreBoardScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DashboardService _dashboard = DashboardService();
  bool _isLoggingOut = false;

  String get _greetingName {
    final user = _authService.currentUser;
    final display = user?.displayName?.trim();
    if (display != null && display.isNotEmpty) return display;

    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientStart,
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      // AuthWrapper listens to authStateChanges() and will navigate to
      // LoginScreen automatically — no manual Navigator push needed.
      await _authService.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitial = _greetingName.toLowerCase() == 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            const GlowOrb(
              top: -160,
              left: -120,
              size: 420,
              color: AppColors.violetOrb,
            ),
            const GlowOrb(
              top: -80,
              right: -140,
              size: 380,
              color: AppColors.accentBlue,
            ),
            SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  // Data is already live via Firestore streams — nothing to do.
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isInitial
                                    ? 'Welcome back'
                                    : 'HI, ${_greetingName[0].toUpperCase()}${_greetingName.substring(1)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Your apartment at a glance',
                                style: AppTextStyles.subtitle,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Log out',
                          onPressed: _isLoggingOut ? null : _logout,
                          icon: _isLoggingOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.icon,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Live Dashboard Components
                    DuesHeroCard(dashboard: _dashboard),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: PendingChoresStat(dashboard: _dashboard),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: PaidThisMonthStat(dashboard: _dashboard),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TodayProgressCard(dashboard: _dashboard),
                    const SizedBox(height: 24),

                    _buildQuickActions(),
                    const SizedBox(height: 28),

                    const SectionTitle(
                      title: 'Upcoming chores',
                      subtitle: 'Live from the house',
                    ),
                    const SizedBox(height: 12),
                    UpcomingChoresList(dashboard: _dashboard),
                    const SizedBox(height: 28),

                    const SectionTitle(
                      title: 'Recent activity',
                      subtitle: 'Latest shared expenses',
                    ),
                    const SizedBox(height: 12),
                    RecentActivityList(dashboard: _dashboard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        Icons.playlist_add_rounded,
        const Color(0xFF7C6BFF),
        const Color(0xFF3B82F6),
        'Add chore',
        'New chores',
      ),
      (
        Icons.payments_rounded,
        const Color(0xFF22C55E),
        const Color(0xFF16A34A),
        'Pay dues',
        'Payments',
      ),
      (
        Icons.receipt_long_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFF97316),
        'Add expense',
        'Expenses',
      ),
      (
        Icons.group_rounded,
        const Color(0xFFEC4899),
        const Color(0xFF8B5CF6),
        'Members',
        'Members',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14, left: 2),
          child: Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              Expanded(
                child: QuickActionButton(
                  icon: actions[i].$1,
                  gradientStart: actions[i].$2,
                  gradientEnd: actions[i].$3,
                  label: actions[i].$4,
                  onTap: () {
                    if (actions[i].$5 == 'New chores') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChoreBoardScreen(),
                        ),
                      );
                    } else {
                      _comingSoon(actions[i].$5);
                    }
                  },
                ),
              ),
              if (i != actions.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

// --- Reusable UI Components ---

class GlowOrb extends StatelessWidget {
  const GlowOrb({
    super.key,
    this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
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

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

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

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (subtitle != null) ...[
          AppPadding.space2,
          Text(subtitle!, style: AppTextStyles.subtitle),
        ],
      ],
    );
  }
}

// --- Dashboard Data Widgets ---

class DuesHeroCard extends StatelessWidget {
  const DuesHeroCard({super.key, required this.dashboard});

  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DuesSummary>(
      stream: dashboard.duesSummary,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.card),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C6BFF), Color(0xFF2F2A7A)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          );
        }

        final dues = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C6BFF), Color(0xFF5B4BE8), Color(0xFF2F2A7A)],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x667C6BFF),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeroTag(label: 'TOTAL DUE'),
                  const Spacer(),
                  _HeroTag(label: 'This month'),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'OUTSTANDING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                  color: Colors.white70,
                ),
              ),
              AppPadding.space2,
              Text(
                AppCurrency.money(dues.remaining),
                style: const TextStyle(
                  fontSize: 46,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: dues.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.20),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF5AD1A0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Paid ${AppCurrency.money(dues.totalPaid)} of ${AppCurrency.money(dues.totalMonthlyDue)} · '
                '${dues.paymentCount} payment${dues.paymentCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.label,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final List<Color> gradient;
  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 28,
              height: 1.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PendingChoresStat extends StatelessWidget {
  const PendingChoresStat({super.key, required this.dashboard});
  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chore>>(
      stream: dashboard.pendingChoresStream,
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return SummaryCard(
          icon: Icons.checklist_rounded,
          gradient: const [Color(0xFF7C6BFF), Color(0xFF3B82F6)],
          label: 'Pending chores',
          value: '$count',
          caption: count == 0
              ? 'All done!'
              : (count == 1 ? '1 to do' : '$count to do'),
        );
      },
    );
  }
}

class PaidThisMonthStat extends StatelessWidget {
  const PaidThisMonthStat({super.key, required this.dashboard});
  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DuesSummary>(
      stream: dashboard.duesSummary,
      builder: (context, snapshot) {
        final paid = snapshot.data?.totalPaid ?? 0;
        return SummaryCard(
          icon: Icons.savings_rounded,
          gradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
          label: 'Paid this month',
          value: AppCurrency.money(paid),
          caption: 'Settled towards dues',
        );
      },
    );
  }
}

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key, required this.dashboard});
  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chore>>(
      stream: dashboard.allChoresStream,
      builder: (context, snapshot) {
        final chores = snapshot.data ?? const <Chore>[];
        final now = DateTime.now();

        final todayChores = chores.where((c) {
          final d = c.dueDate;
          return d != null &&
              d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        }).toList();

        final done = todayChores.where((c) => c.completed).length;
        final total = todayChores.length;
        final progress = total == 0 ? 0.0 : done / total;

        return AppWidgets.glassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5AD1A0), Color(0xFF22C55E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.today_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  AppPadding.space12,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's progress",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Chores scheduled for today',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    total == 0 ? '—' : '$done/$total',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.textMuted.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF5AD1A0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                total == 0
                    ? 'Nothing scheduled for today — enjoy the break.'
                    : (done == total
                          ? "All of today's chores are done. Nice work, team."
                          : '$done of $total done so far today.'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientStart.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingChoresList extends StatelessWidget {
  const UpcomingChoresList({super.key, required this.dashboard});
  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chore>>(
      stream: dashboard.pendingChoresStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          );
        }

        final chores = snapshot.data!;
        if (chores.isEmpty) {
          return AppWidgets.glassCard(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF5AD1A0),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No chores pending. The house is all caught up!',
                    style: AppTextStylesExtended.emptyState,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < chores.length; i++) ...[
              ChoreTile(chore: chores[i]),
              if (i != chores.length - 1) AppPadding.space20,
            ],
          ],
        );
      },
    );
  }
}

class ChoreTile extends StatelessWidget {
  const ChoreTile({super.key, required this.chore});
  final Chore chore;

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kitchen':
        return const Color(0xFFF59E0B);
      case 'bathroom':
        return const Color(0xFF3B82F6);
      case 'living room':
        return const Color(0xFFEC4899);
      case 'cleaning':
      case 'chore':
        return const Color(0xFF22C55E);
      default:
        return AppColors.primary;
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

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${day.day} ${months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(chore.category);

    return AppWidgets.glassCard(
      padding: AppPadding.tileInner,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: AppDecorations.tileIcon(color: color, active: true),
            child: Icon(
              Icons.cleaning_services_rounded,
              color: color,
              size: 20,
            ),
          ),
          AppPadding.space12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStylesExtended.choreTitle,
                ),
                AppPadding.space3,
                Text(
                  '${chore.assignedTo} · ${chore.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStylesExtended.choreSubtitle,
                ),
              ],
            ),
          ),
          AppPadding.space8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chore.points > 0)
                Text(
                  '+${chore.points} pts',
                  style: AppTextStylesExtended.chorePoints,
                ),
              AppPadding.space4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadiiExtended.badge),
                ),
                child: Text(
                  _formatDay(chore.dueDate),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key, required this.dashboard});
  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: dashboard.expensesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          );
        }

        final expenses = snapshot.data!.take(6).toList();
        if (expenses.isEmpty) {
          return AppWidgets.glassCard(
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.icon),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No activity yet. Add the first expense when bills come in.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return AppWidgets.glassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < expenses.length; i++) ...[
                ActivityTile(expense: expenses[i]),
                if (i != expenses.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColorsExtended.divider,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.expense});
  final Expense expense;

  String _formatDay(DateTime? date) {
    if (date == null) return 'No date';
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${day.day} ${months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.tile,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: AppDecorations.tileIcon(
              color: AppColors.primary,
              active: true,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          AppPadding.space12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStylesExtended.activityTitle,
                ),
                AppPadding.space2,
                Text(
                  '${expense.paidBy} · ${_formatDay(expense.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStylesExtended.activitySubtitle,
                ),
              ],
            ),
          ),
          AppPadding.space8,
          Text(
            AppCurrency.money(expense.amount),
            style: AppTextStylesExtended.activityAmount,
          ),
        ],
      ),
    );
  }
}
