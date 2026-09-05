import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class FeeStructurePage extends StatelessWidget {
  const FeeStructurePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Fee Structure',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Fee Category'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: const [
                    ListTile(
                      title: Text('Tuition Fee - B.Tech (CS)'),
                      subtitle: Text('Semester: All | Amount: \$1,500'),
                      trailing: Icon(Icons.edit, color: Colors.blue),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Library Fee'),
                      subtitle: Text('Semester: Annual | Amount: \$100'),
                      trailing: Icon(Icons.edit, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}