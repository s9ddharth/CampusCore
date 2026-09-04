import 'package:flutter/material.dart';
import '../../../layouts/admin_layout.dart';
import '../../../models/student_model.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_dropdown.dart';
import '../../../widgets/common/app_button.dart';

class EditStudentPage extends StatefulWidget {
  final StudentModel student;

  const EditStudentPage({Key? key, required this.student}) : super(key: key);

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _rollController;
  String? _selectedDept;
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _rollController = TextEditingController(text: widget.student.rollNumber);
    _selectedDept = widget.student.department.isNotEmpty ? widget.student.department : null;
    _selectedSemester = widget.student.semester.isNotEmpty ? widget.student.semester : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully!'), backgroundColor: Colors.blue),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Edit Student',
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
                  Text('Update Information for ${widget.student.rollNumber}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AppTextField(
                    controller: _rollController,
                    label: 'Roll Number',
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  AppDropdown<String>(
                    label: 'Department',
                    value: _selectedDept,
                    items: const [
                      DropdownMenuItem(value: 'CS', child: Text('Computer Science')),
                      DropdownMenuItem(value: 'IT', child: Text('Information Technology')),
                    ],
                    onChanged: (val) => setState(() => _selectedDept = val),
                  ),
                  AppDropdown<String>(
                    label: 'Semester',
                    value: _selectedSemester,
                    items: List.generate(8, (i) => DropdownMenuItem(value: '${i+1}', child: Text('Semester ${i+1}'))),
                    onChanged: (val) => setState(() => _selectedSemester = val),
                  ),
                  const SizedBox(height: 32),
                  AppButton(text: 'Update Student', onPressed: _saveChanges),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}