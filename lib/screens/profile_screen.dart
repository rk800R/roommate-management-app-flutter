import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';
import 'members_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _editProfile(BuildContext context, AppService service, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.length < 2) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Name must be at least 2 characters'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              try {
                await service.updateProfile(displayName: name);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Could not update name. $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = AppService();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
          AppWidgets.glowOrb(bottom: -120, right: -100, size: 320, color: AppColors.blueBrand),
        ],
        // Watch the current user's doc so edits reflect instantly.
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: service.currentUserStream(),
          builder: (context, snap) {
            final docData = snap.data?.data() ?? {};
            final name = (docData['displayName']?.toString().isNotEmpty == true)
                ? docData['displayName'].toString()
                : service.displayName;
            final email = service.email;
            final initial = name.isNotEmpty ? name[0] : '?';
            return Column(
              children: [
                AppWidgets.pageHeader(context, 'Profile', showBack: true),
                Expanded(
                  child: ListView(
                    padding: AppPadding.pageHorizontal.copyWith(bottom: 40),
                    children: [
                      // --- Avatar ---
                      Center(
                        child: AppWidgets.userAvatar(
                          initial: initial,
                          size: 96,
                          fontSize: 42,
                          boxShadow: const [AppShadows.logo],
                        ),
                      ),
                      AppPadding.space20,
                      Center(child: Text(name, style: AppTextStyles.heading.copyWith(fontSize: 24))),
                      AppPadding.space4,
                      Center(child: Text(email, style: AppTextStyles.subtitle)),
                      AppPadding.space32,

                      // --- Account ---
                      Text('Account', style: AppTextStyles.sectionHeader),
                      AppPadding.space12,
                      _SettingsTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: () => _editProfile(context, service, name),
                      ),
                      AppPadding.space8,
                      _SettingsTile(
                        icon: Icons.group_outlined,
                        title: 'View Members',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MembersScreen()),
                        ),
                      ),
                      AppPadding.space8,
                      _SettingsTile(
                        icon: Icons.forum_outlined,
                        title: 'Chatrooms',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        ),
                      ),
                      AppPadding.space12,
                      _InfoTile(icon: Icons.apartment, title: 'Apartment ID', value: 'default_apt'),
                      AppPadding.space12,
                      _InfoTile(icon: Icons.email_outlined, title: 'Email', value: email),
                      AppPadding.space12,
                      _InfoTile(icon: Icons.verified_user_outlined, title: 'Status', value: 'Active'),
                      AppPadding.space32,

                      // --- Settings ---
                      Text('Settings', style: AppTextStyles.sectionHeader),
                      AppPadding.space12,
                      _ThemeToggleTile(
                        isDark: themeProvider.isDark,
                        onToggle: () => themeProvider.toggleTheme(),
                      ),
                      AppPadding.space8,
                      _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
                      AppPadding.space8,
                      _SettingsTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
                      AppPadding.space8,
                      _SettingsTile(icon: Icons.info_outline, title: 'About', onTap: () {}),
                      AppPadding.space32,

                      // --- Sign out ---
                      AppWidgets.primaryButton(
                        label: 'Sign Out',
                        onTap: () async {
                          await service.signOut();
                          if (!context.mounted) return;
                          // Pop back to the root (AuthWrapper). Once signed out,
                          // authStateChanges() emits null and AuthWrapper rebuilds
                          // into LoginScreen automatically.
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppWidgets.glassCard(
      padding: AppPadding.tileInner,
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: AppDecorations.summaryIcon(),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.activitySubtitle),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.icon, size: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppWidgets.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.icon),
        title: Text(title, style: AppTextStyles.body),
        trailing: Icon(Icons.chevron_right, color: AppColors.icon),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _ThemeToggleTile({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AppWidgets.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: AppColors.icon,
        ),
        title: Text('Appearance', style: AppTextStyles.body),
        subtitle: Text(isDark ? 'Dark Mode' : 'Light Mode', style: AppTextStyles.activitySubtitle),
        trailing: Switch.adaptive(
          value: isDark,
          onChanged: (_) => onToggle(),
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }
}