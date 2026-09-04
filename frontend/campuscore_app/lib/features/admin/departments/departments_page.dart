import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layouts/admin_layout.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/empty_state.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({Key? key}) : super(key: key);

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentProvider>().fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Departments',
      child: Consumer<DepartmentProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.loading) return const AppLoader();
          if (provider.state == ProviderState.error) {
            return EmptyState(
              title: 'Error Loading Data',
              message: provider.errorMessage,
              icon: Icons.error_outline,
              onRetry: provider.fetchDepartments,
            );
          }
          if (provider.departments.isEmpty) {
            return const EmptyState(
              title: 'No Departments Found',
              message: 'There are currently no departments configured in the system.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.departments.length,
            itemBuilder: (context, index) {
              final dept = provider.departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(child: Text(dept.code)),
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('HOD: ${dept.hodName ?? 'Not Assigned'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail or edit
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}