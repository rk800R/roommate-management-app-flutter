import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';

/// Lists every current member of the apartment (real Firestore users).
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final service = AppService();
    final myId = service.currentUserId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(
            top: -140,
            left: -100,
            size: 360,
            color: AppColors.violetOrb,
          ),
          AppWidgets.glowOrb(
            top: -60,
            right: -120,
            size: 320,
            color: AppColors.blueBrand,
          ),
        ],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, 'Members'),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: service.membersStream(AppService.aptId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: AppPadding.pageHorizontal,
                        child: Text(
                          'Could not load members. ${snapshot.error}',
                          style: AppTextStyles.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final members = snapshot.data!;
                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: AppColors.icon,
                          ),
                          AppPadding.space12,
                          Text(
                            'No members yet',
                            style: AppTextStyles.emptyState,
                          ),
                          AppPadding.space4,
                          Text(
                            'Members join when they sign up',
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: AppPadding.pageList,
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      final member = members[i];
                      final isMe = member['id'] == myId;
                      final name =
                          member['displayName']?.toString() ?? 'Unknown';
                      final email = member['email']?.toString() ?? '';

                      return Padding(
                        padding: AppPadding.bottom12,
                        child: AppWidgets.glassCard(
                          padding: AppPadding.tileInner,
                          child: Row(
                            children: [
                              AppWidgets.userAvatar(initial: name, size: AppRadii.avatarDefault),
                              AppPadding.width14,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: AppTextStyles.activityTitle,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          AppPadding.width8,
                                          Container(
                                            padding: AppPadding.badge,
                                            decoration:
                                                AppDecorations.statusTag(true),
                                            child: Text(
                                              'You',
                                              style: AppTextStyles.smallBadge,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (email.isNotEmpty) ...[
                                      AppPadding.space2,
                                      Text(
                                        email,
                                        style: AppTextStyles.activitySubtitle,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
