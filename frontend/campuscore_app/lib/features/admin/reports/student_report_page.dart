import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class StudentReportPage extends StatelessWidget {
  const StudentReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Student Transcript',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Roll Number', 
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Fetch Transcript')),
              ],
            ),
            const Expanded(
              child: Center(child: Text('Search a student to generate PDF transcript and result overview.')),
            )
          ],
        ),
      ),
    );
  }
}