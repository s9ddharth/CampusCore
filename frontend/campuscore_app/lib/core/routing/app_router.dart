import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../constants/route_names.dart';
import 'route_guards.dart';
import 'route_observer.dart';

// Import Feature Pages
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/admin/dashboard/admin_dashboard_page.dart';
import '../../features/faculty/dashboard/faculty_dashboard_page.dart';
import '../../features/student/dashboard_screen.dart'; // Assuming standard student dashboard

class AppRouter {
  // Global key for navigating without context if absolutely necessary
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.splash,
      observers: [AppRouteObserver()],
      
      // Global redirect logic handled by the RouteGuard
      redirect: (context, state) => RouteGuards.guard(context, state, authProvider),
      
      // Forces the router to re-evaluate redirects if auth state changes
      refreshListenable: authProvider,
      
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginPage(),
        ),
        // Admin Routes
        GoRoute(
          path: RouteNames.adminDashboard,
          builder: (context, state) => const AdminDashboardPage(),
        ),
        // Faculty Routes
        GoRoute(
          path: RouteNames.facultyDashboard,
          builder: (context, state) => const FacultyDashboardPage(),
        ),
        // Student Routes
        GoRoute(
          path: RouteNames.studentDashboard,
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        // NOTE: Additional nested routes (e.g. /admin/students) would be added here
      ],
      
      // Global Error screen for undefined routes
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.toString()}'),
        ),
      ),
    );
  }
}