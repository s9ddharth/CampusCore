import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layouts/admin_layout.dart';
import '../../../providers/faculty_provider.dart';
import '../../../widgets/common/app_loader.dart';

class FacultyPage extends StatefulWidget {
  const FacultyPage({Key? key}) : super(key: key);

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacultyProvider>().fetchFaculty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Faculty Management',
      child: Consumer<FacultyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const AppLoader();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onIcon: const Icon(Icons.add),
                      label: const Text('Add Faculty'),
                      onPressed: () { /* Go to add faculty route */ },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Emp ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Designation')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: provider.facultyList.map((faculty) {
                        return DataRow(cells: [
                          DataCell(Text(faculty.employeeId)),
                          DataCell(Text(faculty.name)),
                          DataCell(Text(faculty.department)),
                          DataCell(Text(faculty.designation)),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () { /* edit */ },
                            ),
                          )
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}