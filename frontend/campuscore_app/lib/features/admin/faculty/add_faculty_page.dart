import 'package:flutter/material.dart';

class AddFacultyPage extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<FacultyDepartmentOption> departments;
  final Future<void> Function(AddFacultyData data)? onSubmit;
  final VoidCallback? onCancel;

  const AddFacultyPage({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.departments = const [],
    this.onSubmit,
    this.onCancel,
  });

  @override
  State<AddFacultyPage> createState() =>
      _AddFacultyPageState();
}

class _AddFacultyPageState
    extends State<AddFacultyPage> {
  final _formKey = GlobalKey<FormState>();

  final _employeeIdController =
      TextEditingController();
  final _nameController =
      TextEditingController();
  final _emailController =
      TextEditingController();
  final _phoneController =
      TextEditingController();
  final _passwordController =
      TextEditingController();

  FacultyDepartmentOption? _selectedDepartment;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.departments.isNotEmpty) {
      _selectedDepartment =
          widget.departments.first;
    }
  }

  @override
  void didUpdateWidget(
    covariant AddFacultyPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (_selectedDepartment != null &&
        !widget.departments.any(
          (department) =>
              department.id ==
              _selectedDepartment!.id,
        )) {
      _selectedDepartment =
          widget.departments.isEmpty
              ? null
              : widget.departments.first;
    }

    if (_selectedDepartment == null &&
        widget.departments.isNotEmpty) {
      _selectedDepartment =
          widget.departments.first;
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final pattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!pattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePhone(
    String? value,
  ) {
    final phone =
        value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final digits =
        phone.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.length < 10 ||
        digits.length > 15) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    final password =
        value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  Future<void> _submit() async {
    if (widget.isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.departments.isNotEmpty &&
        _selectedDepartment == null) {
      _showError(
        'Select a department.',
      );
      return;
    }

    final data = AddFacultyData(
      employeeId:
          _employeeIdController.text.trim(),
      name: _nameController.text.trim(),
      email:
          _emailController.text.trim(),
      phone:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      password:
          _passwordController.text,
      departmentId:
          _selectedDepartment?.id,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(data);
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !widget.isLoading,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _feedback(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.errorMessage != null &&
        widget.errorMessage!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer
              .withValues(alpha: 0.55),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.error
                .withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color:
                  theme.colorScheme.error,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.successMessage != null &&
        widget.successMessage!
            .trim()
            .isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.green
              .withValues(alpha: 0.08),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: Colors.green
                .withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.successMessage!,
                style:
                    theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildForm(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration:
                        BoxDecoration(
                      color: theme.colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
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
                          'Faculty Details',
                          style: theme.textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Create a faculty account and assign it to a department.',
                          style: theme.textTheme
                              .bodySmall
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder:
                    (context, constraints) {
                  final compact =
                      constraints.maxWidth <
                          700;

                  final employeeId =
                      _buildField(
                    label: 'Employee ID',
                    controller:
                        _employeeIdController,
                    hint:
                        'Example: FAC-001',
                    prefixIcon:
                        const Icon(
                      Icons.badge_outlined,
                    ),
                    textInputAction:
                        TextInputAction.next,
                    validator: _required,
                  );

                  final name =
                      _buildField(
                    label: 'Full Name',
                    controller:
                        _nameController,
                    hint:
                        'Faculty member name',
                    prefixIcon:
                        const Icon(
                      Icons.person_outline,
                    ),
                    textInputAction:
                        TextInputAction.next,
                    validator: _required,
                  );

                  final email =
                      _buildField(
                    label: 'Email',
                    controller:
                        _emailController,
                    hint:
                        'faculty@example.com',
                    prefixIcon:
                        const Icon(
                      Icons.email_outlined,
                    ),
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    validator:
                        _validateEmail,
                  );

                  final phone =
                      _buildField(
                    label: 'Phone',
                    controller:
                        _phoneController,
                    hint:
                        'Optional phone number',
                    prefixIcon:
                        const Icon(
                      Icons.phone_outlined,
                    ),
                    keyboardType:
                        TextInputType.phone,
                    textInputAction:
                        TextInputAction.next,
                    validator:
                        _validatePhone,
                  );

                  final password =
                      _buildField(
                    label: 'Initial Password',
                    controller:
                        _passwordController,
                    hint:
                        'Enter a secure password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    validator:
                        _validatePassword,
                    suffixIcon:
                        IconButton(
                      tooltip:
                          _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                      onPressed:
                          widget.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  );

                  final department =
                      DropdownButtonFormField<int>(
                    initialValue:
                        _selectedDepartment
                            ?.id,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Department',
                      prefixIcon:
                          Icon(
                        Icons
                            .account_tree_outlined,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                    items: widget
                        .departments
                        .map(
                          (
                            department,
                          ) =>
                              DropdownMenuItem<int>(
                            value:
                                department
                                    .id,
                            child:
                                Text(
                              department
                                  .name,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        widget.isLoading
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                final selected =
                                    widget
                                        .departments
                                        .firstWhere(
                                  (
                                    item,
                                  ) =>
                                      item.id ==
                                      value,
                                );

                                setState(() {
                                  _selectedDepartment =
                                      selected;
                                });
                              },
                    validator:
                        (_) {
                      if (widget
                              .departments
                              .isEmpty) {
                        return null;
                      }

                      return _selectedDepartment ==
                              null
                          ? 'Select a department'
                          : null;
                    },
                  );

                  if (compact) {
                    return Column(
                      children: [
                        employeeId,
                        const SizedBox(
                            height: 14),
                        name,
                        const SizedBox(
                            height: 14),
                        email,
                        const SizedBox(
                            height: 14),
                        phone,
                        const SizedBox(
                            height: 14),
                        department,
                        const SizedBox(
                            height: 14),
                        password,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                                employeeId,
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child: name,
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: email,
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child: phone,
                          ),
                        ],
                      ),
                      const SizedBox(
                          height: 14),
                      Row(
                        children: [
                          Expanded(
                            child:
                                department,
                          ),
                          const SizedBox(
                              width: 12),
                          Expanded(
                            child:
                                password,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(13),
                decoration:
                    BoxDecoration(
                  color: theme.colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 19,
                      color: theme.colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'The backend remains authoritative for account creation, '
                        'role assignment and access control.',
                        style: theme.textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        widget.isLoading
                            ? null
                            : widget.onCancel ??
                                () => Navigator.of(
                                      context,
                                    ).maybePop(),
                    child:
                        const Text(
                      'Cancel',
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed:
                        widget.isLoading
                            ? null
                            : _submit,
                    icon: widget.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .person_add_outlined,
                          ),
                    label: Text(
                      widget.isLoading
                          ? 'Creating...'
                          : 'Create Faculty',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Faculty'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed:
              widget.isLoading
                  ? null
                  : widget.onCancel ??
                      () =>
                          Navigator.of(
                            context,
                          ).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 900,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Faculty',
                    style: theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Create a faculty account for CampusCore.',
                    style: theme.textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                      height: 20),
                  if (widget.errorMessage !=
                          null ||
                      widget.successMessage !=
                          null) ...[
                    _feedback(context),
                    const SizedBox(
                        height: 16),
                  ],
                  _buildForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultyDepartmentOption {
  final int id;
  final String name;

  const FacultyDepartmentOption({
    required this.id,
    required this.name,
  });
}

class AddFacultyData {
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final String password;
  final int? departmentId;

  const AddFacultyData({
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    this.departmentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'department_id': departmentId,
    };
  }
}