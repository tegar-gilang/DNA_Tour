import 'package:flutter/material.dart';

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
  });

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
    );
  }
}
