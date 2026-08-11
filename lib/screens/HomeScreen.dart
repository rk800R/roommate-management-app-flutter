import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final service = AppService();
    const aptId = AppService.aptId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -160, left: -120, size: 420, color: AppColors.violetOrb),
          AppWidgets.glowOrb(top: -80, right: -140, size: 380, color: AppColors.accentBlue),
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
                  onTap: () => onNavigate?.call(4),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        service.displayName.isNotEmpty ? service.displayName[0] : '?',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
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
                final choreProgress = total > 0 ? (total - pending) / total : 0.0;

                return Column(
                  children: [
                    SummaryCard(
                      icon: Icons.payments,
                      gradient: AppGradients.brand,
                      title: 'Dues Outstanding',
                      value: 'PKR ${data['outstanding'] ?? '0.00'}',
                      subtitle: '${data['paid'] ?? 0} paid · ${data['pending'] ?? 0} pending',
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
                              Text('Chore Completion', style: AppTextStyles.sectionHeader),
                              Text('${(choreProgress * 100).toInt()}%', style: AppTextStyles.activityTitle),
                            ],
                          ),
                          AppPadding.space8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
            AppPadding.space32,

            // --- Quick actions ---
            Text('Quick Actions', style: AppTextStyles.sectionHeader),
            AppPadding.space12,
            Row(
              children: [
                Expanded(
                  child: _ActionItem(
                    icon: Icons.add_task,
                    label: 'Add Chore',
                    onTap: () => onNavigate?.call(1),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.payment,
                    label: 'Pay Dues',
                    onTap: () => onNavigate?.call(2),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.receipt,
                    label: 'Expenses',
                    onTap: () => onNavigate?.call(2),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.article,
                    label: 'Notices',
                    onTap: () => onNavigate?.call(3),
                  ),
                ),
              ],
            ),
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
  const _ActionItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.glassFillInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.activitySubtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}