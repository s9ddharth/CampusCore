import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../constants/route_names.dart';

class RouteGuards {
  /// Core guard that checks if a user is authenticated and routes them 
  /// based on their specific role to prevent cross-role access.
  static String? guard(BuildContext context, GoRouterState state, AuthProvider authProvider) {
    final isAuthenticated = authProvider.state == AuthState.authenticated;
    final isLoginRoute = state.matchedLocation == RouteNames.login;
    final isSplashRoute = state.matchedLocation == RouteNames.splash;

    // Allow unrestricted access to splash screen
    if (isSplashRoute) return null;

    // If not authenticated and not trying to login, redirect to login
    if (!isAuthenticated && !isLoginRoute) {
      return RouteNames.login;
    }

    // If authenticated but trying to access login, redirect to their respective dashboard
    if (isAuthenticated && isLoginRoute) {
      final role = authProvider.user?.role;
      if (role == 'admin') return RouteNames.adminDashboard;
      if (role == 'faculty') return RouteNames.facultyDashboard;
      if (role == 'student') return RouteNames.studentDashboard;
    }

    // --- Role-Based Access Control ---
    if (isAuthenticated) {
      final role = authProvider.user?.role;
      final path = state.matchedLocation;

      if (path.startsWith('/admin') && role != 'admin') {
        return _getFallbackRoute(role);
      }
      if (path.startsWith('/faculty') && role != 'faculty') {
        return _getFallbackRoute(role);
      }
      if (path.startsWith('/student') && role != 'student') {
        return _getFallbackRoute(role);
      }
    }

    return null; // No redirect needed
  }

  static String _getFallbackRoute(String? role) {
    if (role == 'admin') return RouteNames.adminDashboard;
    if (role == 'faculty') return RouteNames.facultyDashboard;
    return RouteNames.studentDashboard; // Default fallback
  }
}