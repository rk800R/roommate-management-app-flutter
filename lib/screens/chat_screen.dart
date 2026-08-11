import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../crud/chat_crud.dart';
import '../providers/theme_provider.dart';
import '../theme/themedata.dart';
import 'chat_room_screen.dart';

/// Lists the apartment's chatrooms and lets you open or create them.
/// The built-in "General" room is auto-created on first launch.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCrud _crud;
  static const String aptId = 'default_apt';

  @override
  void initState() {
    super.initState();
    _crud = ChatCrud(aptId: aptId);
    _crud.ensureDefaultRoom();
  }

  void _createRoom(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Chatroom'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Room name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                _crud.createRoom(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -140, left: -100, size: 360, color: AppColors.violetOrb),
          AppWidgets.glowOrb(top: -60, right: -120, size: 320, color: AppColors.accentBlue),
        ],
        child: Column(
          children: [
            AppWidgets.pageHeader(context, 'Chatrooms', showBack: true),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _crud.getRoomsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rooms = snapshot.data!.docs;
                  if (rooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 64, color: AppColors.icon),
                          AppPadding.space12,
                          Text('No chatrooms yet', style: AppTextStyles.emptyState),
                          AppPadding.space4,
                          Text('Tap + to create a room', style: AppTextStyles.subtitle),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: AppPadding.pageList,
                    itemCount: rooms.length,
                    itemBuilder: (context, i) {
                      final room = rooms[i];
                      final data = room.data() as Map;
                      return Padding(
                        padding: AppPadding.bottom12,
                        child: AppWidgets.glassCard(
                          padding: AppPadding.tileInner,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 44, height: 44,
                              decoration: AppDecorations.summaryIcon(),
                              child: Icon(
                                (data['isDefault'] == true)
                                    ? Icons.campaign_rounded
                                    : Icons.forum_rounded,
                                size: 22, color: Colors.white,
                              ),
                            ),
                            title: Text(
                              data['name'] ?? 'Untitled room',
                              style: AppTextStyles.activityTitle,
                            ),
                            subtitle: Text(
                              (data['lastMessage']?.toString().isNotEmpty == true)
                                  ? data['lastMessage'].toString()
                                  : 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.activitySubtitle,
                            ),
                            trailing: Icon(Icons.chevron_right, color: AppColors.icon),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  roomId: room.id,
                                  roomName: data['name']?.toString() ?? 'Chat',
                                ),
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createRoom(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
