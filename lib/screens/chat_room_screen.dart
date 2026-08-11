import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../crud/chat_crud.dart';
import '../providers/theme_provider.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';

/// A single chatroom's message thread with a real-time composer.
class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  const ChatRoomScreen({super.key, required this.roomId, required this.roomName});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late final ChatCrud _crud;
  final _service = AppService();
  final _inputCtrl = TextEditingController();
  bool _sending = false;

  static const String aptId = 'default_apt';

  @override
  void initState() {
    super.initState();
    _crud = ChatCrud(aptId: aptId);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _crud.sendMessage(
        roomId: widget.roomId,
        text: text,
        senderId: _service.currentUserId ?? 'anon',
        senderName: _service.displayName,
      );
      _inputCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _timeLabel(Timestamp ts) {
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final myId = _service.currentUserId ?? 'anon';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
        ],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, widget.roomName),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getMessagesStream(widget.roomId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 56, color: AppColors.icon),
                          AppPadding.space12,
                          Text('No messages yet', style: AppTextStyles.emptyState),
                          AppPadding.space4,
                          Text('Say hi to your roommates', style: AppTextStyles.subtitle),
                        ],
                      ),
                    );
                  }
                  // Newest-first from Firestore; reverse list so newest sit at the
                  // bottom (reverse:true) — keeps the composer in view.
                  return ListView.builder(
                    reverse: true,
                    padding: AppPadding.pageHorizontal.copyWith(bottom: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[i];
                      final data = msg.data() as Map;
                      final isMine = data['senderId']?.toString() == myId;
                      return _MessageBubble(
                        text: data['text']?.toString() ?? '',
                        sender: data['senderName']?.toString() ?? 'Unknown',
                        time: data['createdAt'] is Timestamp
                            ? _timeLabel(data['createdAt'] as Timestamp)
                            : '',
                        isMine: isMine,
                      );
                    },
                  );
                },
              ),
            ),
            // ─── Composer ─────────────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Container(
                margin: AppPadding.composer,
                padding: AppPadding.composerInner,
                decoration: AppDecorations.inputField(focused: true),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.textMuted),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.icon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String time;
  final bool isMine;
  const _MessageBubble({
    required this.text,
    required this.sender,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
      padding: AppPadding.messageBubble,
      decoration: AppDecorations.messageBubble(isMine: isMine),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Text(sender,
                style: AppTextStyles.activitySubtitle.copyWith(color: AppColors.link)),
            const SizedBox(height: 2),
          ],
          Text(text, style: AppTextStyles.body),
          const SizedBox(height: 2),
          Text(time, style: AppTextStyles.choreDate),
        ],
      ),
    );

    return Padding(
      padding: AppPadding.bubbleItem,
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isMine
            ? [bubble]
            : [
                // Tiny sender initial avatar
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppWidgets.userAvatar(initial: sender, size: 30),
                ),
                bubble,
              ],
      ),
    );
  }
}
