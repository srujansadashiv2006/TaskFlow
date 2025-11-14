import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for haptics
import 'package:task_manager/task_model.dart';
import 'package:confetti/confetti.dart';
// ignore: unused_import
import 'dart:math';

// Reusable card for the Home Screen
class CategoryCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    this.emoji,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null)
              Text(
                emoji!,
                style: const TextStyle(fontSize: 24),
              ),
            if (emoji != null) const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Task Item (with Haptics)
class TaskItem extends StatefulWidget {
  final Task task;
  final Function(String id) onDismissed;
  final Function(Task task) onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dismissible(
          key: Key(widget.task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // --- ADDED HAPTIC FEEDBACK ---
            HapticFeedback.mediumImpact();
            widget.onDismissed(widget.task.id);
          },
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              widget.onTap(widget.task);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: widget.task.isDone,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.task.isDone = value ?? false;
                        if (widget.task.isDone) {
                          _confettiController.play();
                          // --- ADDED HAPTIC FEEDBACK ---
                          HapticFeedback.lightImpact();
                        }
                      });
                    },
                    shape: const CircleBorder(),
                    activeColor: const Color(0xFF3B2E7E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: widget.task.isDone ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.task.priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 10,
          gravity: 0.3,
          emissionFrequency: 0.05,
          maxBlastForce: 10,
          minBlastForce: 5,
        ),
      ],
    );
  }
}