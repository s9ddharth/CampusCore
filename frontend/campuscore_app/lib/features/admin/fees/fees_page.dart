import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';

class FeesPage extends StatelessWidget {
  const FeesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Fees Management',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Student Fee Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to payment page or fee structure
                  },
                  child: const Text('Record Payment'),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Roll No')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Total Due')),
                      DataColumn(label: Text('Paid')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('CS101')),
                        DataCell(Text('John Doe')),
                        DataCell(Text('\$1,600')),
                        DataCell(Text('\$1,600')),
                        DataCell(Chip(label: Text('Cleared'), backgroundColor: Colors.greenAccent)),
                        DataCell(Icon(Icons.receipt)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('CS102')),
                        DataCell(Text('Jane Smith')),
                        DataCell(Text('\$1,600')),
                        DataCell(Text('\$800')),
                        DataCell(Chip(label: Text('Partial'), backgroundColor: Colors.orangeAccent)),
                        DataCell(Icon(Icons.receipt)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}