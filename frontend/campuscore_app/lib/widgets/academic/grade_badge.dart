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
    final value = grade.trim().toUpperCase();

    final Color backgroundColor;
    final Color textColor;

    switch (value) {
      case 'S':
        backgroundColor = Colors.deepPurple.shade100;
        textColor = Colors.deepPurple.shade900;
        break;

      case 'A':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;

      case 'B':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;

      case 'C':
        backgroundColor = Colors.cyan.shade100;
        textColor = Colors.cyan.shade900;
        break;

      case 'D':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;

      case 'E':
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        break;

      case 'F':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;

      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          if (gradePoint != null) ...[
            const SizedBox(width: 6),
            Text(
              gradePoint!.toStringAsFixed(1),
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}