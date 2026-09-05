import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/faculty_provider.dart';

class FacultyDashboardScreen extends StatefulWidget {
  @override
  _FacultyDashboardScreenState createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacultyProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Dashboard')),
      body: Consumer<FacultyProvider>(
        builder: (context, provider, child) {
          if (provider.state == FacultyState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == FacultyState.error) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          if (provider.dashboardData == null) {
            return const Center(child: Text('No data available'));
          }

          final data = provider.dashboardData!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard('Total Students', data.totalStudents.toString(), Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSummaryCard('Pending Marks', data.pendingMarksEntries.toString(), Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Assigned Subjects', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isDesktop ? 2.5 : 3.0,
                      ),
                      itemCount: data.assignedSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = data.assignedSubjects[index];
                        return Card(
                          child: ListTile(
                            title: Text('${subject.subjectCode} - ${subject.name}'),
                            subtitle: Text('Section: ${subject.section} | Students: ${subject.studentCount}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Navigate to subject details/actions
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}