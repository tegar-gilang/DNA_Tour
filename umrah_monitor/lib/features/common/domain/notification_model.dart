import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String dateGroup; // 'Hari Ini', 'Kemarin', 'Minggu Ini'
  final String category; // 'Darurat', 'Perjalanan', 'Aktivitas', 'Sholat', 'Siaran', 'Pertemuan', 'Hotel', 'Keberangkatan Bus', 'Kesehatan', 'Insiden'
  final String priorityLabel; // 'URGEN', 'PENTING', 'PRIORITAS TINGGI', 'RUTIN'
  final IconData icon;
  final Color color;
  final bool isRead;
  final String? incidentId;
  final String? broadcastId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dateGroup,
    required this.category,
    required this.priorityLabel,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.incidentId,
    this.broadcastId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Pemberitahuan';
    final subtitle = json['message']?.toString() ?? '';
    final incidentId = json['sos_incident_id']?.toString();
    final broadcastId = json['broadcast_id']?.toString();
    final type = json['type']?.toString().toLowerCase() ?? '';
    final isRead = json['read_at'] != null;

    String category = 'Umum';
    String priorityLabel = 'RUTIN';
    IconData icon = LucideIcons.bell;
    Color color = AppColors.primary;

    if (type.contains('sos') || incidentId != null) {
      category = 'Darurat';
      priorityLabel = 'URGEN';
      icon = LucideIcons.alertTriangle;
      color = AppColors.emergencyRed;
    } else if (type == 'broadcast' || broadcastId != null) {
      category = 'Siaran';
      priorityLabel = 'PENTING';
      icon = LucideIcons.radio;
      color = const Color(0xFFC27803); // Warm amber gold tone for broadcast
    } else if (type.contains('activity') || type.contains('journey') || type.contains('schedule')) {
      category = 'Aktivitas';
      priorityLabel = 'PENTING';
      icon = LucideIcons.compass;
      color = AppColors.primary;
    }

    String timeFormatted = 'Baru Saja';
    String dateGroup = 'Hari Ini';
    final createdAtStr = json['created_at']?.toString();
    if (createdAtStr != null) {
      final dt = DateTime.tryParse(createdAtStr)?.toLocal();
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        timeFormatted = '$hh:$mm';

        if (diff.inDays == 0 && dt.day == now.day) {
          dateGroup = 'Hari Ini';
        } else if (diff.inDays <= 1) {
          dateGroup = 'Kemarin';
        } else {
          dateGroup = 'Minggu Ini';
        }
      }
    }

    return NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      time: timeFormatted,
      dateGroup: dateGroup,
      category: category,
      priorityLabel: priorityLabel,
      icon: icon,
      color: color,
      isRead: isRead,
      incidentId: incidentId,
      broadcastId: broadcastId,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    String? dateGroup,
    String? category,
    String? priorityLabel,
    IconData? icon,
    Color? color,
    bool? isRead,
    String? incidentId,
    String? broadcastId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      dateGroup: dateGroup ?? this.dateGroup,
      category: category ?? this.category,
      priorityLabel: priorityLabel ?? this.priorityLabel,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      incidentId: incidentId ?? this.incidentId,
      broadcastId: broadcastId ?? this.broadcastId,
    );
  }
}
