import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class ClassResultsPage extends StatelessWidget {
  const ClassResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Class Results',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Section',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'SEC-A', child: Text('CS - Section A')),
                          DropdownMenuItem(value: 'SEC-B', child: Text('CS - Section B')),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Semester',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Semester 1')),
                          DropdownMenuItem(value: '2', child: Text('Semester 2')),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                      child: const Text('Load Results'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.table_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Select a section and semester to view the class performance table.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}