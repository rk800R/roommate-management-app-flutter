import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';
import '../widgets/summary_card.dart';
import 'chore_board_screen.dart';
import 'expense_splitter_screen.dart';
import 'notice_board_screen.dart';
import 'chat_screen.dart';
import 'members_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// One entry per destination — the single source of truth for the Quick
  /// Actions grid. Each destination appears exactly once.
  static List<({IconData icon, String label, Widget screen})> quickActions() {
    return [
      (
        icon: Icons.checklist_rounded,
        label: 'Chores',
        screen: const ChoreBoardScreen(),
      ),
      (
        icon: Icons.receipt_long_rounded,
        label: 'Expenses',
        screen: const ExpenseSplitterScreen(),
      ),
      (
        icon: Icons.article_rounded,
        label: 'Notices',
        screen: const NoticeBoardScreen(),
      ),
      (icon: Icons.forum_rounded, label: 'Chat', screen: const ChatScreen()),
      (
        icon: Icons.group_rounded,
        label: 'Members',
        screen: const MembersScreen(),
      ),
      (
        icon: Icons.person_rounded,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// Quick Actions laid out three per row, with no duplication.
  List<Widget> _buildActionRows(BuildContext context) {
    final actions = quickActions();
    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i += 3) {
      final chunk = actions.sublist(
        i,
        (i + 3) > actions.length ? actions.length : i + 3,
      );
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 3 < actions.length ? 16 : 0),
          child: Row(
            children: [
              for (int j = 0; j < chunk.length; j++) ...[
                Expanded(
                  child: _ActionItem(
                    icon: chunk[j].icon,
                    label: chunk[j].label,
                    onTap: () => _open(context, chunk[j].screen),
                  ),
                ),
                if (j < chunk.length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final service = AppService();
    const aptId = AppService.aptId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(
            top: -160,
            left: -120,
            size: 420,
            color: AppColors.violetOrb,
          ),
          AppWidgets.glowOrb(
            top: -80,
            right: -140,
            size: 380,
            color: AppColors.accentBlue,
          ),
        ],
        child: ListView(
          padding: AppPadding.pageHorizontal.copyWith(top: 16, bottom: 40),
          children: [
            // --- Greeting + avatar ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: AppTextStyles.subtitle),
                      Text(service.displayName, style: AppTextStyles.heading),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _open(context, const ProfileScreen()),
                  child: AppWidgets.userAvatar(
                    initial: service.displayName,
                    size: 48,
                    border: Border.all(color: AppColors.glassBorder, width: 2),
                  ),
                ),
              ],
            ),
            AppPadding.space24,

            // --- Real-time dashboard ---
            StreamBuilder<Map<String, dynamic>>(
              stream: service.dashboardStream(aptId),
              builder: (context, snap) {
                final data = snap.data ?? {};
                final pending = data['pendingChores'] ?? 0;
                final total = data['totalChores'] ?? 1;
                final choreProgress = total > 0
                    ? (total - pending) / total
                    : 0.0;

                return Column(
                  children: [
                    SummaryCard(
                      icon: Icons.payments,
                      gradient: AppGradients.brand,
                      title: 'Dues Outstanding',
                      value: 'PKR ${data['outstanding'] ?? '0.00'}',
                      subtitle:
                          '${data['paid'] ?? 0} paid · ${data['pending'] ?? 0} pending',
                    ),
                    AppPadding.space12,
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.checklist,
                            gradient: AppGradients.brand,
                            title: 'Pending Chores',
                            value: '$pending',
                            subtitle: '${total - pending} of $total done',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.savings,
                            gradient: AppGradients.brandWarm,
                            title: 'Savings',
                            value: 'PKR ${data['savings'] ?? 0}',
                          ),
                        ),
                      ],
                    ),
                    AppPadding.space16,
                    // Progress bar
                    AppWidgets.glassCard(
                      padding: AppPadding.tileInner,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chore Completion',
                                style: AppTextStyles.sectionHeader,
                              ),
                              Text(
                                '${(choreProgress * 100).toInt()}%',
                                style: AppTextStyles.activityTitle,
                              ),
                            ],
                          ),
                          AppPadding.space8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.badge),
                            child: LinearProgressIndicator(
                              value: choreProgress,
                              minHeight: 8,
                              backgroundColor: AppColors.glassFillInput,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            AppPadding.space16,

            // --- Quick actions (every destination, no repetition) ---
            Text('Quick Actions', style: AppTextStyles.sectionHeader),
            AppPadding.space12,
            ..._buildActionRows(context),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 62,
            decoration: AppDecorations.actionTile(),
            child: Icon(icon, color: AppColors.textPrimary, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.activityTitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
