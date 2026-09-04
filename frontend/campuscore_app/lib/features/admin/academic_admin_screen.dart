import 'package:flutter/material.dart';

class AcademicAdminScreen extends StatelessWidget {
  final VoidCallback? onStudentsTap;
  final VoidCallback? onFacultyTap;
  final VoidCallback? onSubjectsTap;
  final VoidCallback? onSectionsTap;
  final VoidCallback? onAssessmentsTap;
  final VoidCallback? onMarksTap;
  final VoidCallback? onResultsTap;
  final VoidCallback? onGradingPolicyTap;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onFeesTap;
  final VoidCallback? onReportsTap;

  const AcademicAdminScreen({
    super.key,
    this.onStudentsTap,
    this.onFacultyTap,
    this.onSubjectsTap,
    this.onSectionsTap,
    this.onAssessmentsTap,
    this.onMarksTap,
    this.onResultsTap,
    this.onGradingPolicyTap,
    this.onAttendanceTap,
    this.onFeesTap,
    this.onReportsTap,
  });

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    List<Widget> children,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 650 ? 1 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              columns == 1 ? 4.0 : 2.8,
          children: children,
        );
      },
    );
  }

  Widget _buildAcademicSetup(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Academic Setup',
          'Manage the academic structure used throughout CampusCore.',
          Icons.account_tree_outlined,
        ),
        const SizedBox(height: 16),
        _buildActionGrid(
          context,
          [
            _actionTile(
              context,
              title: 'Students',
              subtitle:
                  'Add, edit and manage student records.',
              icon: Icons.people_outline,
              onTap: onStudentsTap,
            ),
            _actionTile(
              context,
              title: 'Faculty',
              subtitle:
                  'Manage faculty accounts and assignments.',
              icon: Icons.badge_outlined,
              onTap: onFacultyTap,
            ),
            _actionTile(
              context,
              title: 'Subjects',
              subtitle:
                  'Configure subjects, credits and semesters.',
              icon: Icons.menu_book_outlined,
              onTap: onSubjectsTap,
            ),
            _actionTile(
              context,
              title: 'Sections',
              subtitle:
                  'Manage classes and academic sections.',
              icon: Icons.groups_outlined,
              onTap: onSectionsTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssessment(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Assessment & Results',
          'Control marks, assessments, grading and published results.',
          Icons.assessment_outlined,
        ),
        const SizedBox(height: 16),
        _buildActionGrid(
          context,
          [
            _actionTile(
              context,
              title: 'Assessments',
              subtitle:
                  'Configure CAT, TEE and internal assessments.',
              icon: Icons.event_note_outlined,
              onTap: onAssessmentsTap,
            ),
            _actionTile(
              context,
              title: 'Marks Overview',
              subtitle:
                  'Review student marks before calculation.',
              icon: Icons.fact_check_outlined,
              onTap: onMarksTap,
            ),
            _actionTile(
              context,
              title: 'Results',
              subtitle:
                  'Calculate, review and publish results.',
              icon: Icons.workspace_premium_outlined,
              onTap: onResultsTap,
            ),
            _actionTile(
              context,
              title: 'Grading Policy',
              subtitle:
                  'Configure relative grading and grade bands.',
              icon: Icons.tune_outlined,
              onTap: onGradingPolicyTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperations(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Academic Operations',
          'Monitor attendance, fees and institutional reports.',
          Icons.dashboard_customize_outlined,
        ),
        const SizedBox(height: 16),
        _buildActionGrid(
          context,
          [
            _actionTile(
              context,
              title: 'Attendance',
              subtitle:
                  'Monitor attendance across classes and subjects.',
              icon: Icons.fact_check_outlined,
              onTap: onAttendanceTap,
            ),
            _actionTile(
              context,
              title: 'Fees',
              subtitle:
                  'Manage fee structures, dues and payments.',
              icon: Icons.account_balance_wallet_outlined,
              onTap: onFeesTap,
            ),
            _actionTile(
              context,
              title: 'Reports',
              subtitle:
                  'Generate academic and administrative reports.',
              icon: Icons.file_present_outlined,
              onTap: onReportsTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary
              .withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator Controls',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use these controls to configure academic data '
                  'and oversee the complete student management workflow.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Administration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Administration',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Configure and manage CampusCore academic operations.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoBanner(context),
                const SizedBox(height: 28),
                _buildAcademicSetup(context),
                const SizedBox(height: 32),
                _buildAssessment(context),
                const SizedBox(height: 32),
                _buildOperations(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}