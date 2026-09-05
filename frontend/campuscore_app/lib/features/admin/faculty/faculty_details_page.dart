import 'package:flutter/material.dart';

class FacultyDetailsPage extends StatelessWidget {
  final FacultyDetailsData faculty;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBack;

  const FacultyDetailsPage({
    super.key,
    required this.faculty,
    this.onEdit,
    this.onDelete,
    this.onBack,
  });

  String _displayValue(
    String? value, {
    String fallback = 'Not provided',
  }) {
    if (value == null ||
        value.trim().isEmpty) {
      return fallback;
    }

    return value.trim();
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme
                  .primaryContainer,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme
                      .labelMedium
                      ?.copyWith(
                    color: theme.colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final isActive =
        faculty.status.toUpperCase() ==
            'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(
                alpha: 0.10,
              )
            : theme.colorScheme
                .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green
                  : theme.colorScheme
                      .onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            faculty.status,
            style: theme.textTheme
                .labelMedium
                ?.copyWith(
              color: isActive
                  ? Colors.green.shade700
                  : theme.colorScheme
                      .onSurfaceVariant,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final initials = faculty.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map(
          (part) => part[0].toUpperCase(),
        )
        .join();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: theme
                  .colorScheme
                  .primaryContainer,
              child: Text(
                initials.isEmpty
                    ? '?'
                    : initials,
                style: theme.textTheme
                    .titleLarge
                    ?.copyWith(
                  color: theme.colorScheme
                      .primary,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    faculty.name,
                    style: theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _displayValue(
                      faculty.employeeId,
                    ),
                    style: theme.textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  if (faculty.email
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      faculty.email,
                      style: theme.textTheme
                          .bodySmall
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildStatusBadge(context),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
  ) async {
    if (onDelete == null) {
      return;
    }

    final theme = Theme.of(context);

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Faculty?',
          ),
          content: Text(
            'This will remove the faculty record for '
            '${faculty.name}. This action should only '
            'be performed when the account is no longer required.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(false),
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.error,
                foregroundColor:
                    theme.colorScheme
                        .onError,
              ),
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(true),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete!();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Details',
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: onBack ??
              () =>
                  Navigator.of(
                    context,
                  ).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit faculty',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete faculty',
              onPressed: () =>
                  _confirmDelete(
                context,
              ),
              icon: Icon(
                Icons.delete_outline,
                color:
                    theme.colorScheme.error,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty Profile',
                    style: theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'View account, department and contact information.',
                    style: theme.textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      final twoColumns =
                          constraints.maxWidth >=
                              700;

                      final tiles = [
                        _buildInfoTile(
                          context,
                          icon: Icons.badge_outlined,
                          label:
                              'Employee ID',
                          value:
                              _displayValue(
                            faculty.employeeId,
                          ),
                        ),
                        _buildInfoTile(
                          context,
                          icon:
                              Icons.email_outlined,
                          label: 'Email',
                          value:
                              _displayValue(
                            faculty.email,
                          ),
                        ),
                        _buildInfoTile(
                          context,
                          icon:
                              Icons.phone_outlined,
                          label: 'Phone',
                          value:
                              _displayValue(
                            faculty.phone,
                          ),
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons
                              .account_tree_outlined,
                          label: 'Department',
                          value:
                              _displayValue(
                            faculty
                                .departmentName,
                          ),
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons
                              .verified_user_outlined,
                          label:
                              'Account Status',
                          value:
                              _displayValue(
                            faculty.status,
                          ),
                        ),
                        _buildInfoTile(
                          context,
                          icon: Icons
                              .fingerprint_outlined,
                          label:
                              'User ID',
                          value:
                              faculty.userId
                                  .toString(),
                        ),
                      ];

                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (
                              var i = 0;
                              i < tiles.length;
                              i++
                            ) ...[
                              tiles[i],
                              if (i !=
                                  tiles.length - 1)
                                const SizedBox(
                                  height: 12,
                                ),
                            ],
                          ],
                        );
                      }

                      return Column(
                        children: [
                          for (
                            var i = 0;
                            i < tiles.length;
                            i += 2
                          ) ...[
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Expanded(
                                  child:
                                      tiles[i],
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child:
                                      i + 1 <
                                              tiles.length
                                          ? tiles[
                                              i + 1]
                                          : const SizedBox
                                              .shrink(),
                                ),
                              ],
                            ),
                            if (i + 2 <
                                tiles.length)
                              const SizedBox(
                                height: 12,
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme
                                .colorScheme
                                .primary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              'Faculty permissions and subject access are controlled by the backend. '
                              'This page is for viewing the faculty profile and invoking administrative actions.',
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultyDetailsData {
  final int id;
  final int? userId;
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final int? departmentId;
  final String? departmentName;
  final String status;

  const FacultyDetailsData({
    required this.id,
    this.userId,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    this.departmentId,
    this.departmentName,
    this.status = 'ACTIVE',
  });

  factory FacultyDetailsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final department =
        json['department'];

    return FacultyDetailsData(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']),
      employeeId:
          json['employee_id']?.toString() ??
              '',
      name:
          json['name']?.toString() ??
              '',
      email:
          json['email']?.toString() ??
              '',
      phone:
          json['phone']?.toString(),
      departmentId:
          _toInt(json['department_id']),
      departmentName:
          department is Map<String, dynamic>
              ? department['name']
                  ?.toString()
              : json['department_name']
                  ?.toString(),
      status:
          json['status']?.toString() ??
              'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'department_id': departmentId,
      'department_name':
          departmentName,
      'status': status,
    };
  }

  static int? _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }
}