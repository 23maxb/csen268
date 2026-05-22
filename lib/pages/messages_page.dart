//https://console.firebase.google.com/u/0/project/csen268-ce47d/firestore/databases/-default-/indexes
// use this link to get to the indexes
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/messaging_service.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Future<void> _newMessage(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Message'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'recipient email',
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    try {
      final chatId = await MessagingService.instance.startChatWithEmail(
        result.trim(),
      );
      if (!context.mounted) return;
      context.push(
        '/messages/$chatId?email=${Uri.encodeQueryComponent(result.trim())}',
      );
    } catch (e) {
      if (!context.mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Could not start chat'),
          content: Text(e is StateError ? e.message : '$e'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Messages',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _newMessage(context),
                  child: const Icon(CupertinoIcons.square_pencil, size: 26),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatSummary>>(
              stream: MessagingService.instance.chatsForCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Messages stream error: ${snapshot.error}');
                  debugPrint('Stack: ${snapshot.stackTrace}');
                  return Center(
                    child: SelectableText('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                final chats = snapshot.data!;
                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      'No conversations yet.\nTap the pencil to start one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => Container(
                    margin: const EdgeInsets.only(left: 16),
                    height: 0.5,
                    color: CupertinoColors.separator,
                  ),
                  itemBuilder: (context, i) {
                    final c = chats[i];
                    final other = c.otherEmail(myUid);
                    final time = c.lastMessageAt == null
                        ? ''
                        : DateFormat('h:mm a').format(c.lastMessageAt!);
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push(
                        '/messages/${c.id}?email=${Uri.encodeQueryComponent(other)}',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.systemGrey5,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                other.isNotEmpty ? other[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    other,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
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
    );
  }
}
