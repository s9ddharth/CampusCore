import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class StudentResultsPage extends StatelessWidget {
  const StudentResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Student Results',
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
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Search by Student Roll Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                      child: const Text('Search'),
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
                      Icon(Icons.person_search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Enter a roll number to fetch the detailed semester transcript and CGPA.', style: TextStyle(color: Colors.grey)),
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