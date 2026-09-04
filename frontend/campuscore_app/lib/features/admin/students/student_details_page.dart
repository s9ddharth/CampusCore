import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';
import '../../../models/student_model.dart';
import '../../../widgets/common/app_avatar.dart';

class StudentDetailsPage extends StatelessWidget {
  final StudentModel student;

  const StudentDetailsPage({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Student Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    AppAvatar(name: student.name, radius: 50),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(label: Text(student.rollNumber), backgroundColor: Colors.blue.shade50),
                              const SizedBox(width: 8),
                              Chip(label: Text('Dept: ${student.department}'), backgroundColor: Colors.green.shade50),
                              const SizedBox(width: 8),
                              Chip(label: Text('Sem: ${student.semester}'), backgroundColor: Colors.orange.shade50),
                            ],
                          )
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to edit page
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Academic Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(height: 32),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('Performance charts and GPA history will be rendered here via backend API.', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(height: 32),
                          _buildStatRow('Current CGPA', 'Pending...'),
                          const SizedBox(height: 16),
                          _buildStatRow('Attendance', '85%'),
                          const SizedBox(height: 16),
                          _buildStatRow('Fee Dues', '\$0.00'),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}