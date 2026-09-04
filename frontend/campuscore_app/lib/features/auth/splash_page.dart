import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  final Duration duration;
  final String appName;
  final String tagline;
  final FutureOr<bool> Function()? onInitialization;
  final VoidCallback? onComplete;
  final bool showProgress;

  const SplashPage({
    super.key,
    this.duration = const Duration(milliseconds: 1800),
    this.appName = 'CampusCore',
    this.tagline = 'Integrated Student Management',
    this.onInitialization,
    this.onComplete,
    this.showProgress = true,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  Timer? _timer;
  bool _initializationCompleted = false;
  bool _initializationFailed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(
      begin: 18,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      if (widget.onInitialization != null) {
        final initialized =
            await widget.onInitialization!();

        if (!initialized) {
          _initializationFailed = true;
        }
      }

      _initializationCompleted = true;

      if (!mounted) {
        return;
      }

      _scheduleCompletion();
    } catch (_) {
      _initializationFailed = true;
      _initializationCompleted = true;

      if (!mounted) {
        return;
      }

      _scheduleCompletion();
    }
  }

  void _scheduleCompletion() {
    if (!_initializationCompleted || !mounted) {
      return;
    }

    _timer?.cancel();

    _timer = Timer(
      widget.duration,
      _complete,
    );
  }

  void _complete() {
    if (!mounted) {
      return;
    }

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.75,
        end: 1,
      ).animate(_scaleAnimation),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary
                  .withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.school_rounded,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(
          0,
          _slideAnimation.value,
        ),
        child: Column(
          children: [
            Text(
              widget.appName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.tagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    if (!widget.showProgress) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 180,
            child: _initializationFailed
                ? LinearProgressIndicator(
                    value: 1,
                    color: theme.colorScheme.error,
                    backgroundColor: theme
                        .colorScheme
                        .surfaceContainerHighest,
                  )
                : const LinearProgressIndicator(),
          ),
          const SizedBox(height: 10),
          Text(
            _initializationFailed
                ? 'Unable to initialize'
                : 'Loading CampusCore...',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  _initializationFailed
                      ? theme.colorScheme.error
                      : theme.colorScheme
                          .onSurfaceVariant,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 28),
                  _buildTitle(context),
                  const SizedBox(height: 44),
                  _buildProgress(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}