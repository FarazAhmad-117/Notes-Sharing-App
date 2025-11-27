import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/messaging_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return DummyMessagingRepository();
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.read(messagingRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.getConversations(authState.user!.uid);
});

final messagesProvider = FutureProvider.family<List<Message>, String>((
  ref,
  otherUserId,
) async {
  final repository = ref.read(messagingRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.getMessages(authState.user!.uid, otherUserId);
});

final sendMessageProvider = FutureProvider.family<Message, SendMessageParams>((
  ref,
  params,
) async {
  final repository = ref.read(messagingRepositoryProvider);
  final authState = ref.read(authProvider);
  if (authState.user == null) throw Exception('User not authenticated');

  final message = await repository.sendMessage(
    senderId: authState.user!.uid,
    receiverId: params.receiverId,
    text: params.text,
    noteId: params.noteId,
  );

  // Invalidate messages provider to refresh
  ref.invalidate(messagesProvider(params.receiverId));
  ref.invalidate(conversationsProvider);

  return message;
});

class SendMessageParams {
  final String receiverId;
  final String text;
  final String? noteId;

  SendMessageParams({
    required this.receiverId,
    required this.text,
    this.noteId,
  });
}
