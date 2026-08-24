import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';

import '../domain/chat_model.dart';
import 'chat_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<ConversationModel> _filterConversations(List<ConversationModel> conversations) {
    if (_searchQuery.isEmpty) return conversations;
    final q = _searchQuery.toLowerCase();
    return conversations.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q) ||
          c.roleBadge.toLowerCase().contains(q);
    }).toList();
  }

  void _sendMessage(String conversationId) {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    ref.read(chatProvider.notifier).sendMessage(conversationId, text);
    _messageController.clear();
  }

  void _sendAttachmentSimulation(String conversationId, String type, String name, IconData icon, Color color) {
    ref.read(chatProvider.notifier).sendAttachment(conversationId, type, name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name berhasil dilampirkan.'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(chatProvider);
    final activeConv = chatState.activeConversationId != null
        ? chatState.conversations.firstWhere(
            (c) => c.id == chatState.activeConversationId,
            orElse: () => chatState.conversations.first,
          )
        : null;

    if (activeConv != null) {
      return _buildChatRoomView(context, isDark, activeConv, chatState);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ultra-Clean Minimalist Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  if (context.canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Komunikasi Kloter & Darurat',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sleek Minimalist Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : Colors.transparent,
                    width: 0.8,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Cari percakapan...',
                    hintStyle: TextStyle(fontSize: 13.5, color: AppColors.textSecondaryLight),
                    prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textSecondaryLight),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textSecondaryLight),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Clean Conversation List
            Expanded(
              child: _filterConversations(chatState.conversations).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.messageSquare, size: 36, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pesan tidak ditemukan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba gunakan kata kunci lain.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _filterConversations(chatState.conversations).length,
                      itemBuilder: (context, index) {
                        final c = _filterConversations(chatState.conversations)[index];
                        return _buildConversationRow(c, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationRow(ConversationModel c, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(chatProvider.notifier).selectConversation(c.id);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Proportional Avatar + Online Dot
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      c.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                if (c.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.backgroundDark : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Message Details (Minimalist & Proportional)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Role Badge di sebelah kiri nama, proporsional & compact
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: c.roleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: c.roleColor.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                c.roleBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: c.roleColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: c.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (c.isBroadcastChannel) ...[
                              const SizedBox(width: 4),
                              const Icon(LucideIcons.radio, size: 12, color: AppColors.primary),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.time,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: c.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                          color: c.unreadCount > 0 ? AppColors.primary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: c.unreadCount > 0
                                ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                : AppColors.textSecondaryLight,
                            fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${c.unreadCount}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildChatRoomView(BuildContext context, bool isDark, ConversationModel c, ChatState chatState) {
    final activeMessages = chatState.messages.where((m) => m.conversationId == c.id).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(chatProvider.notifier).selectConversation(null);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: NetworkImage(c.avatarUrl),
                      ),
                      if (c.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: c.roleColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: c.roleColor.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                c.roleBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: c.roleColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          chatState.isTyping ? 'mengetik pesan...' : (c.isOnline ? 'Online • Aktif' : 'Offline'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: chatState.isTyping || c.isOnline ? AppColors.primary : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(LucideIcons.phoneCall, size: 18, color: AppColors.primary),
                      tooltip: 'Panggil',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Memanggil ${c.name}...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(LucideIcons.moreHorizontal, size: 20, color: isDark ? Colors.white70 : AppColors.textPrimaryLight),
                      tooltip: 'Opsi lainnya',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${c.name} • ${c.roleBadge}')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Message Bubbles List (Ultra Clean without Pinned Banner)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: activeMessages.length,
              itemBuilder: (context, index) {
                final m = activeMessages[index];
                final showDateGroup = index == 0 || activeMessages[index - 1].dateGroup != m.dateGroup;

                return Column(
                  children: [
                    if (showDateGroup)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1),
                            ),
                            child: Text(
                              m.dateGroup,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    _buildMessageBubble(m, isDark),
                  ],
                );
              },
            ),
          ),

          // Typing Indicator Pill if active
          if (chatState.isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'mengetik...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Ultra-Minimalist Clean White Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Button
                  PopupMenuButton<String>(
                    icon: Icon(LucideIcons.paperclip, size: 22, color: isDark ? Colors.white70 : AppColors.textPrimaryLight),
                    tooltip: 'Lampirkan berkas',
                    offset: const Offset(0, -170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1.5),
                    ),
                    color: isDark ? AppColors.cardDark : Colors.white,
                    onSelected: (val) {
                      if (val == 'image') {
                        _sendAttachmentSimulation(c.id, 'image', 'Foto_Bersama_Ihram.jpg', LucideIcons.image, AppColors.secondaryDark);
                      } else if (val == 'document') {
                        _sendAttachmentSimulation(c.id, 'document', 'Voucher_Digital_Umrah.pdf', LucideIcons.fileText, AppColors.infoBlue);
                      } else if (val == 'location') {
                        _sendAttachmentSimulation(c.id, 'location', 'Koordinat GPS Langsung ±3m', LucideIcons.mapPin, AppColors.successGreen);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'image',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.image, size: 18, color: AppColors.secondaryDark),
                            const SizedBox(width: 12),
                            Text('Galeri / Foto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'document',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.fileText, size: 18, color: AppColors.infoBlue),
                            const SizedBox(width: 12),
                            Text('Dokumen / PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'location',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 18, color: AppColors.successGreen),
                            const SizedBox(width: 12),
                            Text('Lokasi Langsung', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),

                  // Minimalist Rounded Input Capsule
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(c.id),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondaryLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Minimalist Primary Send Button
                  InkWell(
                    onTap: () => _sendMessage(c.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel m, bool isDark) {
    final bubbleColor = m.isMe
        ? AppColors.primary
        : (isDark ? AppColors.cardDark : Colors.white);
    final textColor = m.isMe
        ? Colors.white
        : (isDark ? Colors.white : AppColors.textPrimaryLight);

    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Minimalist Sender Name above incoming bubble
            if (!m.isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  m.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),

            // Bubble Container
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(m.isMe ? 18 : 4),
                  topRight: Radius.circular(m.isMe ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                border: !m.isMe && !isDark
                    ? Border.all(color: const Color(0xFFD1D5DB), width: 1.5)
                    : (isDark && !m.isMe ? Border.all(color: AppColors.borderDark, width: 1.2) : null),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (m.attachmentType != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m.isMe
                            ? Colors.white.withValues(alpha: 0.18)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.attachmentType == 'image'
                                ? LucideIcons.image
                                : (m.attachmentType == 'document' ? LucideIcons.fileText : LucideIcons.mapPin),
                            size: 18,
                            color: m.isMe ? Colors.white : AppColors.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              m.attachmentName ?? 'Lampiran',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    m.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // Clean Minimalist Timestamp & Checkmark outside/below bubble
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (m.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.checkCheck,
                      size: 14,
                      color: m.isRead ? AppColors.primary : AppColors.textSecondaryLight,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
