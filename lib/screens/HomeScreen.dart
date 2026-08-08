import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../services/DashboardService.dart';
import '../theme/themedata.dart';
import 'LoginScreen.dart';

/// Screen 2 — Dashboard / Overview.
///
/// The landing screen after login. Summarises the apartment's current state
/// with real-time Firestore data:
///   * total remaining dues (hero card, gradient + progress bar),
///   * pending chores and paid-this-month summary cards,
///   * today's chore completion progress,
///   * quick actions, and live upcoming-chores / recent-activity feeds.
///
/// Every summary widget reads from a `Stream` exposed by [DashboardService]
/// and rebuilds automatically whenever Firestore changes (StreamBuilder).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggingOut = false;
  final AuthService _authService = AuthService();
  final DashboardService _dashboard = DashboardService();

  /// A friendly greeting name: display name, else the email local-part,
  /// else "there".
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
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
              top: -80,
              right: -140,
              size: 380,
              color: AppColors.accentBlue,
            ),
            SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  // Firestore re-syncs by itself; the pause only makes the
                  // pull-to-refresh feedback feel deliberate.
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _DuesHeroCard(dashboard: _dashboard),
                    const SizedBox(height: 16),
                    _buildStatRow(),
                    const SizedBox(height: 16),
                    _TodayProgressCard(dashboard: _dashboard),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    const _SectionTitle(
                      title: 'Upcoming chores',
                      subtitle: 'Live from the house',
                    ),
                    const SizedBox(height: 12),
                    _UpcomingChores(dashboard: _dashboard),
                    const SizedBox(height: 28),
                    const _SectionTitle(
                      title: 'Recent activity',
                      subtitle: 'Latest shared expenses',
                    ),
                    const SizedBox(height: 12),
                    _RecentActivity(dashboard: _dashboard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    final isInitial = _greetingName.toLowerCase() == 'there';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isInitial ? 'Welcome back' : 'Hei, $_greetingName',
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
              : const Icon(Icons.logout_rounded, color: AppColors.icon),
        ),
      ],
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _PendingChoresStat(dashboard: _dashboard),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _PaidThisMonthStat(dashboard: _dashboard),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = <(IconData, Color, Color, String, String)>[
      (Icons.playlist_add_rounded, const Color(0xFF7C6BFF),
          const Color(0xFF3B82F6), 'Add chore', 'New chores'),
      (Icons.payments_rounded, const Color(0xFF22C55E),
          const Color(0xFF16A34A), 'Pay dues', 'Payments'),
      (Icons.receipt_long_rounded, const Color(0xFFF59E0B),
          const Color(0xFFF97316), 'Add expense', 'Expenses'),
      (Icons.group_rounded, const Color(0xFFEC4899),
          const Color(0xFF8B5CF6), 'Members', 'Members'),
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
                child: _QuickActionButton(
                  icon: actions[i].$1,
                  gradientStart: actions[i].$2,
                  gradientEnd: actions[i].$3,
                  label: actions[i].$4,
                  onTap: () => _comingSoon(actions[i].$5),
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


/// A soft radial glow placed behind the content, mirroring the login screen.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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

/// A frosted, translucent rounded container — the shared "glass card".
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

/// Section heading with a title and an optional muted subtitle.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

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
          const SizedBox(height: 2),
          Text(subtitle!, style: AppTextStyles.subtitle),
        ],
      ],
    );
  }
}

/// Renders a [DateTime] as a short relative day when possible.
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${day.day} ${months[day.month - 1]}';
}


/// Hero summary card: total dues remaining with a paid-progress bar.
/// Streams live from Firestore via [DashboardService.duesSummary].
class _DuesHeroCard extends StatelessWidget {
  const _DuesHeroCard({required this.dashboard});

  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DuesSummary>(
      stream: dashboard.duesSummary,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const _HeroSkeleton();
        final dues = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C6BFF),
                Color(0xFF5B4BE8),
                Color(0xFF2F2A7A),
              ],
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
                  const _HeroTag(label: 'TOTAL DUE'),
                  const Spacer(),
                  const _HeroTag(label: 'This month'),
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
              const SizedBox(height: 2),
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
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF5AD1A0)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Paid ${AppCurrency.money(dues.totalPaid)} of '
                '${AppCurrency.money(dues.totalMonthlyDue)} · '
                '${dues.paymentCount} '
                'payment${dues.paymentCount == 1 ? '' : 's'}',
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

/// Small pill label used inside the hero card.
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

/// Placeholder shown while the dues stream is still loading.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C6BFF), Color(0xFF2F2A7A)],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


/// Summary card with a gradient background. Used by the small stat tiles.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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

/// "Pending chores" statistic, live from Firestore.
class _PendingChoresStat extends StatelessWidget {
  const _PendingChoresStat({required this.dashboard});

  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chore>>(
      stream: dashboard.pendingChoresStream,
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return _SummaryCard(
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

/// "Paid this month" statistic, live from Firestore.
class _PaidThisMonthStat extends StatelessWidget {
  const _PaidThisMonthStat({required this.dashboard});

  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DuesSummary>(
      stream: dashboard.duesSummary,
      builder: (context, snapshot) {
        final paid = snapshot.data?.totalPaid ?? 0;
        return _SummaryCard(
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


/// "Today's progress" glass card showing how many of today's chores are done.
class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({required this.dashboard});

  final DashboardService dashboard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chore>>(
      stream: dashboard.allChoresStream,
      builder: (context, snapshot) {
        final chores = snapshot.data ?? const <Chore>[];
        final now = DateTime.now();
        bool isToday(DateTime? d) {
          if (d == null) return false;
          final day = DateTime(d.year, d.month, d.day);
          final today = DateTime(now.year, now.month, now.day);
          return day == today;
        }

        final todayChores = chores.where((c) => isToday(c.dueDate)).toList();
        final done = todayChores.where((c) => c.completed).length;
        final total = todayChores.length;
        final progress = total == 0 ? 0.0 : done / total;

        return _GlassCard(
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
                  const SizedBox(width: 12),
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
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF5AD1A0)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                total == 0
                    ? 'Nothing scheduled for today — enjoy the break.'
                    : (done == total
                        ? 'All of today\'s chores are done. Nice work, team.'
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

/// A circular gradient quick-action button with a label underneath.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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


/// Color tint for a chore category, used for its icon chip.
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

/// Live list of pending chores, soonest due first.
class _UpcomingChores extends StatelessWidget {
  const _UpcomingChores({required this.dashboard});

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
          return const _GlassCard(
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF5AD1A0)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No chores pending. The house is all caught up!',
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
        return Column(
          children: [
            for (var i = 0; i < chores.length; i++) ...[
              _ChoreTile(chore: chores[i]),
              if (i != chores.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

/// A single pending chore row in a glass card.
class _ChoreTile extends StatelessWidget {
  const _ChoreTile({required this.chore});

  final Chore chore;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(chore.category);
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cleaning_services_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${chore.assignedTo} · ${chore.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chore.points > 0)
                Text(
                  '+${chore.points} pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
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


/// Live, abbreviated list of the most recent shared expenses.
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.dashboard});

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
          return const _GlassCard(
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
        return _GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < expenses.length; i++) ...[
                _ActivityTile(expense: expenses[i]),
                if (i != expenses.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A single row in the recent-activity feed.
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.paidBy} · ${_formatDay(expense.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppCurrency.money(expense.amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

