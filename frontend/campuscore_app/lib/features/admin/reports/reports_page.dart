import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Academic Reports',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildReportTile(context, 'Class Reports', Icons.assessment, 'Generate section-wise academic reports.'),
            _buildReportTile(context, 'Student Reports', Icons.person_search, 'Generate individual student transcripts.'),
            _buildReportTile(context, 'Financial Reports', Icons.account_balance_wallet, 'View fee collection data.'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String title, IconData icon, String desc) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}