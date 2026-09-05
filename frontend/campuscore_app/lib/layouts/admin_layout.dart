import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AdminLayout({Key? key, required this.child, required this.title}) : super(key: key);

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
      backgroundColor: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Text('CampusCore Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          _buildNavItem(context, 'Dashboard', Icons.dashboard, RouteNames.adminDashboard, currentRoute),
          _buildNavItem(context, 'Departments', Icons.domain, '/admin/departments', currentRoute),
          _buildNavItem(context, 'Faculty', Icons.people, '/admin/faculty', currentRoute),
          _buildNavItem(context, 'Students', Icons.school, '/admin/students', currentRoute),
          _buildNavItem(context, 'Subjects', Icons.book, '/admin/subjects', currentRoute),
          _buildNavItem(context, 'Fees', Icons.account_balance_wallet, '/admin/fees', currentRoute),
          _buildNavItem(context, 'Results', Icons.assessment, '/admin/results', currentRoute),
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
              Text('Hello, ${user?.name ?? 'Admin'}'),
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