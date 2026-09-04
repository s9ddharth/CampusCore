import 'package:flutter/material.dart';

class GradeChip extends StatelessWidget {
  final String grade;
  final double? gradePoint;

  const GradeChip({
    super.key,
    required this.grade,
    this.gradePoint,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedGrade = grade.trim().toUpperCase();

    final Color backgroundColor;
    final Color foregroundColor;

    switch (normalizedGrade) {
      case 'S':
        backgroundColor = Colors.deepPurple.shade100;
        foregroundColor = Colors.deepPurple.shade900;
        break;

      case 'A':
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade900;
        break;

      case 'B':
        backgroundColor = Colors.blue.shade100;
        foregroundColor = Colors.blue.shade900;
        break;

      case 'C':
        backgroundColor = Colors.cyan.shade100;
        foregroundColor = Colors.cyan.shade900;
        break;

      case 'D':
        backgroundColor = Colors.orange.shade100;
        foregroundColor = Colors.orange.shade900;
        break;

      case 'E':
        backgroundColor = Colors.amber.shade100;
        foregroundColor = Colors.amber.shade900;
        break;

      case 'F':
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade900;
        break;

      default:
        backgroundColor = Colors.grey.shade200;
        foregroundColor = Colors.grey.shade800;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            normalizedGrade.isEmpty
                ? '-'
                : normalizedGrade,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (gradePoint != null) ...[
            const SizedBox(width: 5),
            Text(
              gradePoint!.toStringAsFixed(1),
              style: TextStyle(
                color: foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}