import 'package:flutter/material.dart';

class GradeBadge extends StatelessWidget {
  final String grade;
  final double? gradePoint;

  const GradeBadge({
    super.key,
    required this.grade,
    this.gradePoint,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedGrade = grade.trim().toUpperCase();

    final Color background;
    final Color foreground;

    switch (normalizedGrade) {
      case 'S':
        background = Colors.deepPurple.shade100;
        foreground = Colors.deepPurple.shade900;
        break;
      case 'A':
        background = Colors.green.shade100;
        foreground = Colors.green.shade900;
        break;
      case 'B':
        background = Colors.blue.shade100;
        foreground = Colors.blue.shade900;
        break;
      case 'C':
        background = Colors.cyan.shade100;
        foreground = Colors.cyan.shade900;
        break;
      case 'D':
        background = Colors.orange.shade100;
        foreground = Colors.orange.shade900;
        break;
      case 'E':
        background = Colors.amber.shade100;
        foreground = Colors.amber.shade900;
        break;
      case 'F':
        background = Colors.red.shade100;
        foreground = Colors.red.shade900;
        break;
      default:
        background = Colors.grey.shade200;
        foreground = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            normalizedGrade.isEmpty
                ? '-'
                : normalizedGrade,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (gradePoint != null) ...[
            const SizedBox(width: 6),
            Text(
              gradePoint!.toStringAsFixed(1),
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}