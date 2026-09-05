import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';

class FacultyLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const FacultyLayout({Key? key, required this.child, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: Text(title)),
      drawer: isDesktop ? null : _buildSidebar(context),
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 250, child: _buildSidebar(context)),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopBar(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppColors.secondary, // Differentiating faculty layout slightly
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.secondary),
            child: Center(
              child: Text('Faculty Portal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          _buildNavItem(context, 'Dashboard', Icons.dashboard, RouteNames.facultyDashboard, currentRoute),
          _buildNavItem(context, 'Assigned Subjects', Icons.library_books, '/faculty/subjects', currentRoute),
          _buildNavItem(context, 'Attendance Entry', Icons.co_present, RouteNames.facultyAttendance, currentRoute),
          _buildNavItem(context, 'Marks Entry', Icons.edit_document, RouteNames.facultyMarks, currentRoute),
          _buildNavItem(context, 'Class Results', Icons.bar_chart, '/faculty/results', currentRoute),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route, String currentRoute) {
    final isSelected = currentRoute.startsWith(route) && (route != '/' || currentRoute == '/');
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
        context.go(route);
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('Prof. ${user?.name ?? 'Faculty'}'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: 'Logout',
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go(RouteNames.login);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}