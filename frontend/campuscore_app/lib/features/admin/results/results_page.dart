import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';
import 'package:go_router/go_router.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Academic Results',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage and view student academic performance. All calculations (GPA/CGPA) are handled by the core server.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                _buildActionCard(
                  context,
                  title: 'Class Results',
                  description: 'View consolidated results and GPA for an entire section.',
                  icon: Icons.groups,
                  onTap: () {
                    // Navigate to class results
                    // context.go('/admin/results/class');
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Student Results',
                  description: 'Search and view detailed transcripts for individual students.',
                  icon: Icons.person,
                  onTap: () {
                    // Navigate to student results
                    // context.go('/admin/results/student');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}