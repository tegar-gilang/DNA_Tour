import 'package:flutter/material.dart';

class UmrahGuideModel {
  final String id;
  final int stepNumber;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String explanation;
  final IconData icon;
  final bool isCompleted;

  const UmrahGuideModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.explanation,
    required this.icon,
    this.isCompleted = false,
  });

  UmrahGuideModel copyWith({
    String? id,
    int? stepNumber,
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? explanation,
    IconData? icon,
    bool? isCompleted,
  }) {
    return UmrahGuideModel(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      explanation: explanation ?? this.explanation,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
