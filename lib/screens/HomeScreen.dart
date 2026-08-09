import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';
import '../widgets/summary_card.dart';
import 'ChoreBoardScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AppService();
    const aptId = 'default_apt';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -160, left: -120, size: 420, color: AppColors.violetOrb),
          AppWidgets.glowOrb(top: -80, right: -140, size: 380, color: AppColors.accentBlue),
        ],
        child: ListView(
          padding: AppPadding.pageHorizontal.copyWith(top: 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back, ${service.displayName}', style: AppTextStyles.heading),
                      const Text('Your apartment at a glance', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
                IconButton(onPressed: () => service.signOut(), icon: const Icon(Icons.logout, color: AppColors.icon)),
              ],
            ),
            AppPadding.space20,
            StreamBuilder<Map<String, dynamic>>(
              stream: service.dashboardStream(aptId),
              builder: (context, snap) {
                final data = snap.data ?? {};
                return Column(
                  children: [
                    SummaryCard(
                      icon: Icons.payments,
                      gradient: AppGradients.brand,
                      title: 'Dues Outstanding',
                      value: 'PKR ${data['outstanding'] ?? 0}',
                      subtitle: 'Paid ${data['paid'] ?? 0} this month',
                    ),
                    AppPadding.space12,
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.checklist,
                            gradient: AppGradients.brand,
                            title: 'Pending Chores',
                            value: '${data['pendingChores'] ?? 0}',
                          ),
                        ),
                        AppPadding.space12,
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
                  ],
                );
              },
            ),
            AppPadding.space32,
            const Text('Quick Actions', style: AppTextStyles.sectionHeader),
            AppPadding.space12,
            _QuickActions(),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionItem(icon: Icons.add_task, label: 'Add Chore', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChoreBoardScreen()))),
        _ActionItem(icon: Icons.payment, label: 'Pay Dues', onTap: () {}),
        _ActionItem(icon: Icons.receipt, label: 'Expense', onTap: () {}),
        _ActionItem(icon: Icons.people, label: 'Members', onTap: () {}),
      ],
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
    return Column(
      children: [
        IconButton.filled(onPressed: onTap, icon: Icon(icon), style: IconButton.styleFrom(backgroundColor: AppColors.glassFillInput)),
        AppPadding.space4,
        Text(label, style: AppTextStyles.activitySubtitle),
      ],
    );
  }
}
