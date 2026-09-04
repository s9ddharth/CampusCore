import 'package:flutter/material.dart';

class GradeChip extends StatelessWidget {
  final String grade;

  const GradeChip({Key? key, required this.grade}) : super(key: key);

  Color _getGradeColor() {
    switch (grade.toUpperCase()) {
      case 'S': return Colors.purple;
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'E': return Colors.redAccent;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        grade,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: _getGradeColor(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}