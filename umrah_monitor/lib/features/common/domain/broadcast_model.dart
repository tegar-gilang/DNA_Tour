import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
/// Model representing a broadcast fetched from `/api/broadcasts`.
/// All fields are nullable except those that are guaranteed by the backend
/// (`id`, `title`, `message`, `created_at`).
class Broadcast {
  final String id;
  final String title;
  final String message;
  final String? category;
  final String? priority;
  final DateTime createdAt;
  final String? senderName;
  final String? broadcastId;

  const Broadcast({
    required this.id,
    required this.title,
    required this.message,
    this.category,
    this.priority,
    required this.createdAt,
    this.senderName,
    this.broadcastId,
  });

  /// Factory constructor that tolerates missing / malformed fields.
  factory Broadcast.fromJson(Map<String, dynamic> json) {
    return Broadcast(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      category: json['category']?.toString(),
      priority: json['priority']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      senderName: json['sender_name']?.toString(),
      broadcastId: json['broadcast_id']?.toString(),
    );
  }

  // UI helpers -------------------------------------------------------------
  IconData get icon {
    if (broadcastId != null) return Icons.rss_feed;
    if (priority?.toLowerCase() == 'high') return Icons.priority_high;
    return Icons.notifications;
  }

  Color get color {
    if (broadcastId != null) return const Color(0xFFC27803); // amber-ish
    if (priority?.toLowerCase() == 'high') return AppColors.emergencyRed;
    return AppColors.primary;
  }

  String get formattedTime {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get dateGroup {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays == 0 && createdAt.day == now.day) return 'Hari Ini';
    if (diff.inDays == 1) return 'Kemarin';
    return 'Minggu Ini';
  }
}
