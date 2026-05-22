import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderEmail;
  final String text;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderEmail: data['senderEmail'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}

class ChatSummary {
  final String id;
  final List<String> participantIds;
  final List<String> participantEmails;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastSenderId;

  ChatSummary({
    required this.id,
    required this.participantIds,
    required this.participantEmails,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
  });

  String otherEmail(String myUid) {
    final idx = participantIds.indexOf(myUid);
    if (idx == -1 || participantEmails.length < 2) {
      return participantEmails.isNotEmpty ? participantEmails.first : '';
    }
    return participantEmails[1 - idx];
  }

  factory ChatSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['lastMessageAt'];
    return ChatSummary(
      id: doc.id,
      participantIds:
          (data['participantIds'] as List?)?.cast<String>() ?? const [],
      participantEmails:
          (data['participantEmails'] as List?)?.cast<String>() ?? const [],
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: ts is Timestamp ? ts.toDate() : null,
      lastSenderId: data['lastSenderId'] as String? ?? '',
    );
  }
}

class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _chatIdFor(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Ensures a `users/{uid}` doc exists keyed for email lookup.
  Future<void> upsertCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;
    final email = user.email!.toLowerCase();
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Find a user by email. Returns (uid, email) or null.
  Future<({String uid, String email})?> findUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first.data();
    return (uid: d['uid'] as String, email: d['email'] as String);
  }

  Stream<List<ChatSummary>> chatsForCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: user.uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ChatSummary.fromDoc).toList());
  }

  Stream<List<ChatMessage>> messages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Starts (or returns existing) chat with the user matching [email].
  /// Returns the chatId, or throws if the email isn't a registered user.
  Future<String> startChatWithEmail(String email) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.email == null) {
      throw StateError('Not signed in.');
    }
    final myEmail = me.email!.toLowerCase();
    final target = await findUserByEmail(email);
    if (target == null) {
      throw StateError('No user found with that email.');
    }
    if (target.uid == me.uid) {
      throw StateError("You can't message yourself.");
    }
    final chatId = _chatIdFor(me.uid, target.uid);
    final ref = _db.collection('chats').doc(chatId);
    await ref.set({
      'participantIds': [me.uid, target.uid]..sort(),
      'participantEmails': () {
        final ids = [me.uid, target.uid]..sort();
        return ids[0] == me.uid
            ? [myEmail, target.email]
            : [target.email, myEmail];
      }(),
    }, SetOptions(merge: true));
    return chatId;
  }

  Future<void> sendMessage(String chatId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) throw StateError('Not signed in.');
    final email = me.email?.toLowerCase() ?? '';
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': me.uid,
      'senderEmail': email,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      chatRef,
      {
        'lastMessage': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': me.uid,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}
