import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class ClassReportPage extends StatelessWidget {
  const ClassReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Class Analytics Report',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Section', border: OutlineInputBorder()),
                    items: const [DropdownMenuItem(value: 'SEC-A', child: Text('CS - Section A'))],
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Generate Report')),
              ],
            ),
            const Expanded(
              child: Center(child: Text('Select a section to view average, pass/fail counts, and grade distributions.')),
            )
          ],
        ),
      ),
    );
  }
}