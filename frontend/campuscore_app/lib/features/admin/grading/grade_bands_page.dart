import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class GradeBandsPage extends StatelessWidget {
  const GradeBandsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Grade Bands',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Configure the institutional grade boundaries (S, A, B, etc.) mapped to API logic.'),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: ListView(
                  children: const [
                    ListTile(title: Text('S Grade'), subtitle: Text('90 - 100 Marks | 10 Points'), trailing: Icon(Icons.edit)),
                    Divider(),
                    ListTile(title: Text('A Grade'), subtitle: Text('80 - 89 Marks | 9 Points'), trailing: Icon(Icons.edit)),
                    Divider(),
                    ListTile(title: Text('B Grade'), subtitle: Text('70 - 79 Marks | 8 Points'), trailing: Icon(Icons.edit)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}