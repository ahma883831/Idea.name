import 'package:flutter/material.dart';

enum BlockCategory { grammar, listening, work, business, other }

extension BlockCategoryX on BlockCategory {
  String get label {
    switch (this) {
      case BlockCategory.grammar:
        return 'گرامر';
      case BlockCategory.listening:
        return 'شنیداری';
      case BlockCategory.work:
        return 'کار';
      case BlockCategory.business:
        return 'شرکت';
      case BlockCategory.other:
        return 'سایر';
    }
  }

  Color get color {
    switch (this) {
      case BlockCategory.grammar:
        return const Color(0xFFB026FF); // neon purple
      case BlockCategory.listening:
        return const Color(0xFF00F5FF); // neon cyan
      case BlockCategory.work:
        return const Color(0xFFFFC400); // neon amber
      case BlockCategory.business:
        return const Color(0xFF39FF14); // neon green
      case BlockCategory.other:
        return const Color(0xFFFF10F0); // neon pink
    }
  }

  static BlockCategory fromString(String s) {
    return BlockCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => BlockCategory.other,
    );
  }
}

class TimeBlock {
  final String id;
  String title;
  BlockCategory category;
  int startMinutes; // minutes since midnight
  int endMinutes;
  bool completed;
  final String date; // yyyy-MM-dd

  TimeBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.startMinutes,
    required this.endMinutes,
    required this.date,
    this.completed = false,
  });

  double get hours => (endMinutes - startMinutes) / 60.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'completed': completed,
        'date': date,
      };

  factory TimeBlock.fromJson(Map<String, dynamic> json) => TimeBlock(
        id: json['id'],
        title: json['title'],
        category: BlockCategoryX.fromString(json['category']),
        startMinutes: json['startMinutes'],
        endMinutes: json['endMinutes'],
        completed: json['completed'] ?? false,
        date: json['date'],
      );

  String get timeRangeLabel {
    String fmt(int m) {
      final h = m ~/ 60;
      final mm = m % 60;
      return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }

    return '${fmt(startMinutes)} - ${fmt(endMinutes)}';
  }
}
