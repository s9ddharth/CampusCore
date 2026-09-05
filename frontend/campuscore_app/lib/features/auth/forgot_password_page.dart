import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;
  final bool isLoading;
  final String? message;
  final String? error;
  final Future<void> Function(String email)? onSubmit;
  final VoidCallback? onBackToLogin;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail,
    this.isLoading = false,
    this.message,
    this.error,
    this.onSubmit,
    this.onBackToLogin,
  });

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(
      text: widget.initialEmail ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
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

    if (widget.onSubmit == null) {
      return;
    }

    await widget.onSubmit!(
      _emailController.text.trim(),
    );
  }

  Widget _buildBrand(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.lock_reset_outlined,
            size: 38,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your registered email address and we will '
          'send instructions to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.error != null &&
        widget.error!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer
              .withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
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
              size: 19,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.message != null &&
        widget.message!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 19,
              color: Colors.green,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.isLoading
              ? null
              : widget.onBackToLogin ??
                  () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                children: [
                  _buildBrand(context),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              enabled: !widget.isLoading,
                              keyboardType:
                                  TextInputType.emailAddress,
                              textInputAction:
                                  TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.email,
                              ],
                              onFieldSubmitted: (_) =>
                                  _submit(),
                              decoration:
                                  const InputDecoration(
                                labelText: 'Email',
                                hintText:
                                    'you@example.com',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                ),
                                border:
                                    OutlineInputBorder(),
                              ),
                              validator:
                                  _validateEmail,
                            ),
                            const SizedBox(height: 18),
                            if (widget.error != null ||
                                widget.message != null) ...[
                              _buildFeedback(context),
                              const SizedBox(height: 16),
                            ],
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed:
                                    widget.isLoading
                                        ? null
                                        : _submit,
                                icon: widget.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons
                                            .send_outlined,
                                      ),
                                label: Text(
                                  widget.isLoading
                                      ? 'Sending...'
                                      : 'Send Reset Instructions',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: widget.isLoading
                                  ? null
                                  : widget
                                          .onBackToLogin ??
                                      () => Navigator.of(
                                        context,
                                      ).maybePop(),
                              child: const Text(
                                'Back to Login',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security_outlined,
                        size: 16,
                        color: theme.colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Use the email associated with your '
                          'CampusCore account.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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