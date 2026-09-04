import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_dropdown.dart';
import '../../../widgets/common/app_button.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  String? _selectedDept;
  String? _selectedSemester;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would call context.read<StudentProvider>().addStudent(...) here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Add New Student',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Registration Details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                  ),
                  AppTextField(
                    controller: _rollNoController,
                    label: 'Roll Number (e.g., CS2023001)',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Roll Number is required' : null,
                  ),
                  AppDropdown<String>(
                    label: 'Department',
                    value: _selectedDept,
                    items: const [
                      DropdownMenuItem(value: 'CS', child: Text('Computer Science')),
                      DropdownMenuItem(value: 'IT', child: Text('Information Technology')),
                      DropdownMenuItem(value: 'ME', child: Text('Mechanical Engineering')),
                    ],
                    onChanged: (val) => setState(() => _selectedDept = val),
                    validator: (val) => val == null ? 'Please select a department' : null,
                  ),
                  AppDropdown<String>(
                    label: 'Current Semester',
                    value: _selectedSemester,
                    items: List.generate(8, (i) => DropdownMenuItem(value: '${i+1}', child: Text('Semester ${i+1}'))),
                    onChanged: (val) => setState(() => _selectedSemester = val),
                    validator: (val) => val == null ? 'Please select a semester' : null,
                  ),
                  const SizedBox(height: 32),
                  AppButton(text: 'Save Student Record', onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}