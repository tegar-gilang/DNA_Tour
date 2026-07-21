import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';

class ConversationItem {
  final String id;
  final String name;
  final String roleBadge; // 'TOUR LEADER', 'MUTAWIF', 'OPERASIONAL', 'INFORMASI', 'DARURAT'
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isBroadcastChannel;
  final Color roleColor;

  const ConversationItem({
    required this.id,
    required this.name,
    required this.roleBadge,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isBroadcastChannel = false,
    required this.roleColor,
  });
}

class ChatMessageItem {
  final String id;
  final String senderName;
  final String text;
  final String time;
  final String dateGroup; // 'Kemarin', 'Hari Ini'
  final bool isMe;
  final bool isRead;
  final String? attachmentType; // 'image', 'document', 'location'
  final String? attachmentName;

  const ChatMessageItem({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.dateGroup,
    required this.isMe,
    this.isRead = true,
    this.attachmentType,
    this.attachmentName,
  });
}

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  ConversationItem? _activeConversation;
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  final List<ConversationItem> _conversations = const [
    ConversationItem(
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
  ];

  final List<ChatMessageItem> _activeMessages = [
    ChatMessageItem(
      id: 'm1',
      senderName: 'Ust. H. Muhammad Ridwan (TL)',
      text: 'Assalamu\'alaikum seluruh jamaah Kloter 4 VIP. Mohon pastikan ID Card digital selalu siap saat beraktivitas bersama di seputar Masjidil Haram.',
      time: '10:15 WAS',
      dateGroup: 'Kemarin',
      isMe: false,
    ),
    ChatMessageItem(
      id: 'm2',
      senderName: 'Ust. Ibrahim Al-Madani (Mutawif)',
      text: 'Alhamdulillah, panduan doa Tawaf dan Sa\'i serta jadwal kegiatan harian sudah siap. Kita akan kumpul di lobi siang ini.',
      time: '10:18 WAS',
      dateGroup: 'Kemarin',
      isMe: false,
      attachmentType: 'document',
      attachmentName: 'Panduan_Doa_Tawaf_Sai.pdf',
    ),
    ChatMessageItem(
      id: 'm3',
      senderName: 'Anda (Jamaah)',
      text: 'Wa\'alaikumussalam Ustadz. Alhamdulillah kami dari kamar 1408 bersiap menuju lobi untuk shalat Zuhur berjamaah.',
      time: '11:30 WAS',
      dateGroup: 'Hari Ini',
      isMe: true,
      isRead: true,
    ),
    ChatMessageItem(
      id: 'm4',
      senderName: 'H. Sulaiman (Jamaah)',
      text: 'Alhamdulillah rombongan kamar 1402 juga siap menuju lobi utama.',
      time: '11:31 WAS',
      dateGroup: 'Hari Ini',
      isMe: false,
    ),
    ChatMessageItem(
      id: 'm5',
      senderName: 'Ust. H. Muhammad Ridwan (TL)',
      text: 'Alhamdulillah! Sampai jumpa di lobi utama pukul 12:00 WAS ya Bapak/Ibu sekalian.',
      time: '11:34 WAS',
      dateGroup: 'Hari Ini',
      isMe: false,
    ),
  ];

  List<ConversationItem> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    final q = _searchQuery.toLowerCase();
    return _conversations.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q) ||
          c.roleBadge.toLowerCase().contains(q);
    }).toList();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    setState(() {
      _activeMessages.add(ChatMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Anda',
        text: text,
        time: 'Baru saja',
        dateGroup: 'Hari Ini',
        isMe: true,
        isRead: false,
      ));
    });
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _activeMessages.add(ChatMessageItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderName: _activeConversation?.name ?? 'Ust. Muhammad Ridwan',
            text: 'Baik, terima kasih! Semoga Allah memudahkan dan melancarkan ibadah Anda.',
            time: 'Baru saja',
            dateGroup: 'Hari Ini',
            isMe: false,
          ));
        });
      }
    });
  }

  void _sendAttachmentSimulation(String type, String name, IconData icon, Color color) {
    final typeId = type == 'image'
        ? 'foto'
        : (type == 'document' ? 'dokumen' : 'lokasi');
    setState(() {
      _activeMessages.add(ChatMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Anda',
        text: 'Melampirkan $typeId:',
        time: 'Baru saja',
        dateGroup: 'Hari Ini',
        isMe: true,
        attachmentType: type,
        attachmentName: name,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name berhasil dilampirkan.'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_activeConversation != null) {
      return _buildChatRoomView(context, isDark);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesan',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Komunikasi Kloter & Darurat',
                          style: GoogleFonts.outfit(
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
                  style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Cari percakapan...',
                    hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: AppColors.textSecondaryLight),
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
              child: _filteredConversations.isEmpty
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
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba gunakan kata kunci lain.',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        final c = _filteredConversations[index];
                        return _buildConversationRow(c, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationRow(ConversationItem c, bool isDark) {
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
            setState(() {
              _activeConversation = c;
            });
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
                                style: GoogleFonts.outfit(
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
                                style: GoogleFonts.outfit(
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
                        style: GoogleFonts.outfit(
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
                          style: GoogleFonts.outfit(
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
                            style: GoogleFonts.outfit(
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

  // Active Chat Room View (Ultra-Minimalist Clean White Apple Style)
  Widget _buildChatRoomView(BuildContext context, bool isDark) {
    final c = _activeConversation!;

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
                      setState(() {
                        _activeConversation = null;
                      });
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
                                style: GoogleFonts.outfit(
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
                                style: GoogleFonts.outfit(
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
                          _isTyping ? 'mengetik pesan...' : (c.isOnline ? 'Online • Aktif' : 'Offline'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isTyping || c.isOnline ? AppColors.primary : AppColors.textSecondaryLight,
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
              itemCount: _activeMessages.length,
              itemBuilder: (context, index) {
                final m = _activeMessages[index];
                final showDateGroup = index == 0 || _activeMessages[index - 1].dateGroup != m.dateGroup;

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
                              style: GoogleFonts.outfit(
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
          if (_isTyping)
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
                        style: GoogleFonts.outfit(
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
                        _sendAttachmentSimulation('image', 'Foto_Bersama_Ihram.jpg', LucideIcons.image, AppColors.secondaryDark);
                      } else if (val == 'document') {
                        _sendAttachmentSimulation('document', 'Voucher_Digital_Umrah.pdf', LucideIcons.fileText, AppColors.infoBlue);
                      } else if (val == 'location') {
                        _sendAttachmentSimulation('location', 'Koordinat GPS Langsung ±3m', LucideIcons.mapPin, AppColors.successGreen);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'image',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.image, size: 18, color: AppColors.secondaryDark),
                            const SizedBox(width: 12),
                            Text('Galeri / Foto', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'document',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.fileText, size: 18, color: AppColors.infoBlue),
                            const SizedBox(width: 12),
                            Text('Dokumen / PDF', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'location',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 18, color: AppColors.successGreen),
                            const SizedBox(width: 12),
                            Text('Lokasi Langsung', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
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
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: GoogleFonts.outfit(
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
                    onTap: _sendMessage,
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

  Widget _buildMessageBubble(ChatMessageItem m, bool isDark) {
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
                  style: GoogleFonts.outfit(
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
                              style: GoogleFonts.outfit(
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
                    style: GoogleFonts.outfit(
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
                    style: GoogleFonts.outfit(
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
