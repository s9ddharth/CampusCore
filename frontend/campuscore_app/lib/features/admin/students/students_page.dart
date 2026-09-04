import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layouts/admin_layout.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/common/app_loader.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Students Directory',
      child: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoader(message: 'Loading students directory...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Roll Number...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: () { 
                        // Route to AddStudentPage
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Student'),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: provider.students.isEmpty 
                    ? const Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Center(child: Text('No students found.', style: TextStyle(color: Colors.grey))),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          columns: const [
                            DataColumn(label: Text('Roll Number')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Department')),
                            DataColumn(label: Text('Semester')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: provider.students.map((student) {
                            return DataRow(
                              cells: [
                                DataCell(Text(student.rollNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(student.name)),
                                DataCell(Text(student.department)),
                                DataCell(Text(student.semester)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.blue),
                                        tooltip: 'View Profile',
                                        onPressed: () {
                                          // Route to StudentDetailsPage
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        tooltip: 'Edit Student',
                                        onPressed: () {
                                          // Route to EditStudentPage
                                        },
                                      ),
                                    ],
                                  )
                                ),
                              ],
                            );
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