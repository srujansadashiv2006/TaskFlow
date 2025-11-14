import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Task {
  final String id;
  String title;
  final DateTime date;
  bool isDone;
  Priority priority;

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.isDone = false,
    this.priority = Priority.low,
  });

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
      default:
        return Colors.green;
    }
  }
}