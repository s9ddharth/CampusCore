import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class GradingPolicyPage extends StatelessWidget {
  const GradingPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Grading Policy',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GPA/CGPA Calculation Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Include Internal Marks in Final GPA'),
                value: true,
                onChanged: (val) {},
              ),
              SwitchListTile(
                title: const Text('Strict Attendance Penalty applied to Grades'),
                value: false,
                onChanged: (val) {},
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () {}, child: const Text('Save Policy'))
            ],
          ),
        ),
      ),
    );
  }
}