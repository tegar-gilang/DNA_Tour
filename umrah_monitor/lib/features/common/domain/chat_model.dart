import 'package:flutter/material.dart';

class ConversationModel {
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

  const ConversationModel({
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

  ConversationModel copyWith({
    String? id,
    String? name,
    String? roleBadge,
    String? avatarUrl,
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isOnline,
    bool? isBroadcastChannel,
    Color? roleColor,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      roleBadge: roleBadge ?? this.roleBadge,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isBroadcastChannel: isBroadcastChannel ?? this.isBroadcastChannel,
      roleColor: roleColor ?? this.roleColor,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderName;
  final String text;
  final String time;
  final String dateGroup; // 'Kemarin', 'Hari Ini'
  final bool isMe;
  final bool isRead;
  final String? attachmentType; // 'image', 'document', 'location'
  final String? attachmentName;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderName,
    required this.text,
    required this.time,
    required this.dateGroup,
    required this.isMe,
    this.isRead = true,
    this.attachmentType,
    this.attachmentName,
  });

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderName,
    String? text,
    String? time,
    String? dateGroup,
    bool? isMe,
    bool? isRead,
    String? attachmentType,
    String? attachmentName,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      time: time ?? this.time,
      dateGroup: dateGroup ?? this.dateGroup,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}
