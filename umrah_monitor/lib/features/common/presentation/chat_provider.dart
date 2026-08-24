import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/chat_model.dart';

class ChatState {
  final List<ConversationModel> conversations;
  final List<ChatMessageModel> messages;
  final String? activeConversationId;
  final bool isTyping;

  const ChatState({
    required this.conversations,
    required this.messages,
    this.activeConversationId,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ConversationModel>? conversations,
    List<ChatMessageModel>? messages,
    String? activeConversationId,
    bool? isTyping,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(const ChatState(
          conversations: [
            ConversationModel(
              id: 'g1',
              name: 'Grup Kloter 4 VIP (TL, Mutawif & Jamaah)',
              roleBadge: 'GRUP KLOTER',
              avatarUrl: 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?auto=format&fit=crop&w=200&q=80',
              lastMessage: 'Ust. H. Muhammad Ridwan (TL): Alhamdulillah! Sampai jumpa di lobi utama pukul 12:00 WAS ya.',
              time: '11:34 WAS',
              unreadCount: 1,
              isOnline: true,
              isBroadcastChannel: false,
              roleColor: AppColors.primary,
            ),
          ],
          messages: [
            ChatMessageModel(
              id: 'm1',
              conversationId: 'g1',
              senderName: 'Ust. H. Muhammad Ridwan (TL)',
              text: 'Assalamu\'alaikum seluruh jamaah Kloter 4 VIP. Mohon pastikan ID Card digital selalu siap saat beraktivitas bersama di seputar Masjidil Haram.',
              time: '10:15 WAS',
              dateGroup: 'Kemarin',
              isMe: false,
            ),
            ChatMessageModel(
              id: 'm2',
              conversationId: 'g1',
              senderName: 'Ust. Ibrahim Al-Madani (Mutawif)',
              text: 'Alhamdulillah, panduan doa Tawaf dan Sa\'i serta jadwal kegiatan harian sudah siap. Kita akan kumpul di lobi siang ini.',
              time: '10:18 WAS',
              dateGroup: 'Kemarin',
              isMe: false,
              attachmentType: 'document',
              attachmentName: 'Panduan_Doa_Tawaf_Sai.pdf',
            ),
            ChatMessageModel(
              id: 'm3',
              conversationId: 'g1',
              senderName: 'Anda (Jamaah)',
              text: 'Wa\'alaikumussalam Ustadz. Alhamdulillah kami dari kamar 1408 bersiap menuju lobi untuk shalat Zuhur berjamaah.',
              time: '11:30 WAS',
              dateGroup: 'Hari Ini',
              isMe: true,
              isRead: true,
            ),
            ChatMessageModel(
              id: 'm4',
              conversationId: 'g1',
              senderName: 'H. Sulaiman (Jamaah)',
              text: 'Alhamdulillah rombongan kamar 1402 juga siap menuju lobi utama.',
              time: '11:31 WAS',
              dateGroup: 'Hari Ini',
              isMe: false,
            ),
            ChatMessageModel(
              id: 'm5',
              conversationId: 'g1',
              senderName: 'Ust. H. Muhammad Ridwan (TL)',
              text: 'Alhamdulillah! Sampai jumpa di lobi utama pukul 12:00 WAS ya Bapak/Ibu sekalian.',
              time: '11:34 WAS',
              dateGroup: 'Hari Ini',
              isMe: false,
            ),
          ],
        ));

  void selectConversation(String? id) {
    state = state.copyWith(activeConversationId: id);
    if (id != null) {
      // Clear unread count for selected conversation
      final updatedConv = state.conversations.map((c) {
        if (c.id == id) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
      state = state.copyWith(conversations: updatedConv);
    }
  }

  void sendMessage(String conversationId, String text) {
    final newMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderName: 'Anda',
      text: text,
      time: 'Baru saja',
      dateGroup: 'Hari Ini',
      isMe: true,
      isRead: false,
    );

    final updatedMessages = [...state.messages, newMsg];
    final updatedConv = state.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(lastMessage: 'Anda: $text', time: 'Baru saja');
      }
      return c;
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      conversations: updatedConv,
      isTyping: true,
    );

    // Simulate auto-reply from mutawif/tour leader
    Future.delayed(const Duration(milliseconds: 1800), () {
      final replyMsg = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        senderName: 'Ust. H. Muhammad Ridwan (TL)',
        text: 'Baik, terima kasih! Semoga Allah memudahkan dan melancarkan ibadah Anda.',
        time: 'Baru saja',
        dateGroup: 'Hari Ini',
        isMe: false,
      );

      state = state.copyWith(
        messages: [...state.messages, replyMsg],
        isTyping: false,
      );
    });
  }

  void sendAttachment(String conversationId, String type, String name) {
    final typeId = type == 'image'
        ? 'foto'
        : (type == 'document' ? 'dokumen' : 'lokasi');
    final newMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderName: 'Anda',
      text: 'Melampirkan $typeId: $name',
      time: 'Baru saja',
      dateGroup: 'Hari Ini',
      isMe: true,
      attachmentType: type,
      attachmentName: name,
    );

    state = state.copyWith(
      messages: [...state.messages, newMsg],
    );
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
