import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/academic/grade_chip.dart';

class StudentDashboardScreen extends StatefulWidget {
  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProviderState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == ProviderState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchDashboard(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
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
                    Text('Welcome, ${data.name}', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('CGPA', data.cgpa.toStringAsFixed(2)),
                        _buildStatCard('Attendance', '${data.attendancePercentage}%'),
                        _buildStatCard('Fees Due', '\$${data.feesDue}'),
                        _buildStatCard('Semester', data.semester),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Recent Results', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildResultsTable(data.recentResults, isDesktop),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable(List recentResults, bool isDesktop) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Grade')),
            DataColumn(label: Text('Points')),
          ],
          rows: recentResults.map((subject) {
            return DataRow(
              cells: [
                DataCell(Text(subject.subjectName)),
                DataCell(GradeChip(grade: subject.grade)),
                DataCell(Text(subject.gradePoint.toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}