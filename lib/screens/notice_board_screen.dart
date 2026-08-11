import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../crud/notice_crud.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});
  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  late final NoticeCrud _crud;
  final _service = AppService();
  static const String aptId = 'default_apt';

  @override
  void initState() {
    super.initState();
    _crud = NoticeCrud(aptId: aptId);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
        ],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, 'Notice Board', showBack: true),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getNoticesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notices = snapshot.data!.docs;
                  if (notices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: AppColors.icon),
                          AppPadding.space12,
                          Text('No notices yet', style: AppTextStyles.emptyState),
                          AppPadding.space4,
                          Text('Tap + to post an announcement', style: AppTextStyles.subtitle),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: AppPadding.pageList,
                    itemCount: notices.length,
                    itemBuilder: (context, i) {
                      final notice = notices[i];
                      final data = notice.data() as Map;
                      final authorId = data['authorId'] as String? ?? '';
                      final currentUserId = _service.currentUser?.uid ?? '';
                      final canDelete = authorId == currentUserId || authorId.isEmpty;

                      return Dismissible(
                        key: ValueKey(notice.id),
                        direction: canDelete
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: AppPadding.pageHorizontal,
                          margin: AppPadding.bottom12,
                          decoration: AppDecorations.dismissibleBackground(),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _crud.deleteNotice(notice.id),
                        child: _NoticeCard(notice: notice),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoticeDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            AppPadding.space12,
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                _crud.addNotice(
                  title: titleCtrl.text,
                  content: contentCtrl.text.isEmpty ? '—' : contentCtrl.text,
                  author: _service.displayName,
                  authorId: _service.currentUser?.uid ?? 'anonymous',
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}

// ─── Notice Card ──────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final QueryDocumentSnapshot notice;
  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final data = notice.data() as Map;
    final title = data['title'] ?? 'Untitled';
    final content = data['content'] ?? '';
    final author = data['author'] ?? 'Unknown';
    final rawTs = data['createdAt'];

    String timeAgo = 'Just now';
    if (rawTs is Timestamp) {
      final dt = rawTs.toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        timeAgo = 'Just now';
      } else if (diff.inHours < 1) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    }

    return Padding(
      padding: AppPadding.bottom12,
      child: AppWidgets.glassCard(
        padding: AppPadding.tileInner,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: AppDecorations.summaryIcon(),
                  child: const Icon(Icons.campaign_rounded, size: 18, color: Colors.white),
                ),
                AppPadding.width12,
                Expanded(
                  child: Text(title, style: AppTextStyles.activityTitle.copyWith(fontSize: 16)),
                ),
              ],
            ),
            if (content.toString().isNotEmpty) ...[
              AppPadding.space12,
              Text(content, style: AppTextStyles.body),
            ],
            AppPadding.space12,
            // Author + timestamp
            Row(
              children: [
                AppWidgets.userAvatar(initial: author, size: AppRadii.avatarSmall, fontSize: 11),
                AppPadding.width8,
                Text(author, style: AppTextStyles.activitySubtitle),
                const Spacer(),
                Text(timeAgo, style: AppTextStyles.choreDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}