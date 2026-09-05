// CAMPUSCORE PS-6 ERP - REPAIRED MAIN.DART
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseUrl = 'http://127.0.0.1:8000';

const Color kPrimary = Color(0xFF02C39A);
const Color kDark = Color(0xFF10302B);
const Color kBackground = Color(0xFFF5F7F6);
const Color kMuted = Color(0xFF6E938D);
const Color kSoft = Color(0xFFE7F5F1);
const Color kAccent = Color(0xFF8FF0D6);
const Color kText = Color(0xFF18332E);

final Api api = Api();

void main() {
  runApp(const CampusCoreApp());
}

// ============================================================================
// API
// ============================================================================

class Api {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _headers(),
    );
  }

  Future<http.Response> post(
    String path, {
    Object? body,
  }) async {
    return http.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path, {
    Object? body,
  }) async {
    return http.put(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    return http.delete(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _headers(),
    );
  }
}

// ============================================================================
// APP
// ============================================================================

class CampusCoreApp extends StatelessWidget {
  const CampusCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusCore',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: scheme,
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFFDDEBE6),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFDDEBE6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFDDEBE6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: kPrimary,
              width: 1.4,
            ),
          ),
        ),
      ),
      home: const SessionGate(),
    );
  }
}

// ============================================================================
// SESSION
// ============================================================================

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (!mounted) return;

    setState(() {
      loggedIn = token != null && token.isNotEmpty;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SplashPage();
    }

    if (loggedIn) {
      return const AppShell();
    }

    return LoginPage(
      onLoggedIn: () {
        setState(() => loggedIn = true);
      },
    );
  }
}

// ============================================================================
// SPLASH
// ============================================================================

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(
              size: 72,
              dark: false,
            ),
            SizedBox(height: 18),
            Text(
              'CAMPUSCORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'One Record. Every Module.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: kPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN
// ============================================================================

class LoginPage extends StatefulWidget {
  final VoidCallback onLoggedIn;

  const LoginPage({
    super.key,
    required this.onLoggedIn,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(
    text: 'admin@erp.local',
  );

  final password = TextEditingController(
    text: 'Admin@123',
  );

  bool obscure = true;
  bool loading = false;
  String? error;

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => error = 'Enter email and password.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await api.post(
        '/api/auth/login',
        body: {
          'email': email.text.trim(),
          'password': password.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'access_token',
          data['access_token'].toString(),
        );

        await prefs.setString(
          'user',
          jsonEncode(data['user']),
        );

        widget.onLoggedIn();
      } else {
        setState(() {
          error = apiError(response);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Cannot connect to FastAPI at $apiBaseUrl';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 850;

    final form = Padding(
      padding: const EdgeInsets.all(34),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 490),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: kText,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Sign in to the CampusCore ERP workspace.',
              style: TextStyle(
                color: kMuted,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onSubmitted: (_) => login(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => obscure = !obscure);
                  },
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              onSubmitted: (_) => login(),
            ),
            if (error != null) ...[
              const SizedBox(height: 13),
              ErrorBanner(message: error!),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : login,
                icon: loading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  loading ? 'Signing in...' : 'Sign in',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: loading
                    ? null
                    : () async {
                        final result = await Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountPage(adminMode: false),
                          ),
                        );
                        if (!mounted || result is! Map) return;
                        final createdEmail = result['email']?.toString() ?? '';
                        final createdPassword = result['password']?.toString() ?? '';
                        if (createdEmail.isNotEmpty) {
                          email.text = createdEmail;
                        }
                        if (createdPassword.isNotEmpty) {
                          password.text = createdPassword;
                        }
                        setState(() {
                          error = null;
                        });
                      },
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                ),
                label: const Text(
                  'Create an account',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const InfoBox(
              title: 'Demo accounts',
              lines: [
                'Admin: admin@erp.local / Admin@123',
                'Faculty: faculty@erp.local / Faculty@123',
                'Student: student1@erp.local / Student@123',
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: narrow
                    ? Column(
                        children: [
                          const LoginBrandPanel(),
                          form,
                        ],
                      )
                    : Row(
                        children: [
                          const Expanded(
                            child: LoginBrandPanel(),
                          ),
                          Expanded(
                            child: form,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      color: kDark,
      padding: const EdgeInsets.all(46),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandMark(
            size: 64,
            dark: false,
          ),
          SizedBox(height: 26),
          Text(
            'CAMPUSCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'One Record. Every Module. Zero Reconciliation.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28),
          Text(
            'Student Management\nAttendance\nFees\nExams & Marks\nAcademic Evaluation\nGPA / CGPA\nReports & Analytics',
            style: TextStyle(
              color: Colors.white70,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// APP SHELL
// ============================================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Map<String, dynamic> user = {};
  int index = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final response = await api.get('/api/auth/me');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          user = Map<String, dynamic>.from(
            data['user'] ?? {},
          );
        });
      }
    } catch (_) {}
  }

  String get role =>
      '${user['role'] ?? 'ADMIN'}'.toUpperCase();

  String get email =>
      '${user['email'] ?? 'ERP User'}';

  List<NavItem> get items {
    if (role == 'FACULTY') {
      return const [
        NavItem(
          'Dashboard',
          Icons.dashboard_outlined,
          Icons.dashboard_rounded,
        ),
        NavItem(
          'Students',
          Icons.people_outline,
          Icons.people_rounded,
        ),
        NavItem(
          'Attendance',
          Icons.fact_check_outlined,
          Icons.fact_check_rounded,
        ),
        NavItem(
          'Exams & Marks',
          Icons.edit_note_outlined,
          Icons.edit_note_rounded,
        ),
        NavItem(
          'Results',
          Icons.bar_chart_outlined,
          Icons.bar_chart_rounded,
        ),
        NavItem(
          'Reports',
          Icons.file_present_outlined,
          Icons.file_present_rounded,
        ),
      ];
    }

    if (role == 'STUDENT') {
      return const [
        NavItem(
          'Dashboard',
          Icons.dashboard_outlined,
          Icons.dashboard_rounded,
        ),
        NavItem(
          'My Record',
          Icons.person_outline,
          Icons.person_rounded,
        ),
        NavItem(
          'Attendance',
          Icons.fact_check_outlined,
          Icons.fact_check_rounded,
        ),
        NavItem(
          'Fees',
          Icons.payments_outlined,
          Icons.payments_rounded,
        ),
        NavItem(
          'Results',
          Icons.school_outlined,
          Icons.school_rounded,
        ),
        NavItem(
          'Reports',
          Icons.file_present_outlined,
          Icons.file_present_rounded,
        ),
      ];
    }

    return const [
      NavItem(
        'Dashboard',
        Icons.dashboard_outlined,
        Icons.dashboard_rounded,
      ),
      NavItem(
        'Students',
        Icons.people_outline,
        Icons.people_rounded,
      ),
      NavItem(
        'Faculty',
        Icons.badge_outlined,
        Icons.badge_rounded,
      ),
      NavItem(
        'Academic Setup',
        Icons.account_tree_outlined,
        Icons.account_tree_rounded,
      ),
      NavItem(
        'Attendance',
        Icons.fact_check_outlined,
        Icons.fact_check_rounded,
      ),
      NavItem(
        'Fees',
        Icons.payments_outlined,
        Icons.payments_rounded,
      ),
      NavItem(
        'Exams & Marks',
        Icons.edit_note_outlined,
        Icons.edit_note_rounded,
      ),
      NavItem(
        'Results',
        Icons.bar_chart_outlined,
        Icons.bar_chart_rounded,
      ),
      NavItem(
        'Grading Policy',
        Icons.rule_outlined,
        Icons.rule_rounded,
      ),
      NavItem(
        'Accounts',
        Icons.manage_accounts_outlined,
        Icons.manage_accounts_rounded,
      ),
      NavItem(
        'Reports',
        Icons.file_present_outlined,
        Icons.file_present_rounded,
      ),
    ];
  }

  Widget pageFor(String label) {
    switch (label) {
      case 'Students':
      case 'My Record':
        return StudentListPage(
          studentOnly: role == 'STUDENT',
        );

      case 'Faculty':
        return const FacultyPage();

      case 'Academic Setup':
        return const AcademicSetupPage();

      case 'Attendance':
        return const AttendancePage();

      case 'Fees':
        return const FeesPage();

      case 'Exams & Marks':
        return const MarksPage();

      case 'Results':
        return const ResultsPage();

      case 'Grading Policy':
        return const PolicyPage();

      case 'Accounts':
        return const AccountPage(
          adminMode: true,
        );

      case 'Reports':
        return const ReportsPage();

      default:
        return DashboardPage(
          role: role,
        );
    }
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('access_token');
    await prefs.remove('user');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoggedIn: () {},
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = items;

    if (index >= nav.length) {
      index = 0;
    }

    final compact =
        MediaQuery.sizeOf(context).width < 1050;

    final current = nav[index];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        leading: compact
            ? Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(
                      Icons.menu_rounded,
                    ),
                  );
                },
              )
            : null,
        title: Row(
          children: [
            if (!compact) ...[
              const BrandMark(
                size: 40,
                dark: true,
              ),
              const SizedBox(width: 11),
            ],
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  current.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: kText,
                  ),
                ),
                Text(
                  roleLabel(role),
                  style: const TextStyle(
                    color: kMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!compact)
            Padding(
              padding:
                  const EdgeInsets.only(right: 12),
              child: RoleBadge(
                role: roleLabel(role),
                email: email,
              ),
            ),
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: compact
          ? AppDrawer(
              items: nav,
              selected: index,
              email: email,
              role: roleLabel(role),
              onSelected: (value) {
                setState(() => index = value);
                Navigator.pop(context);
              },
              onLogout: logout,
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            AppNavigationRail(
              items: nav,
              selected: index,
              email: email,
              role: roleLabel(role),
              onSelected: (value) {
                setState(() => index = value);
              },
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(
                  current.label,
                ),
                child: pageFor(
                  current.label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData outlined;
  final IconData filled;

  const NavItem(
    this.label,
    this.outlined,
    this.filled,
  );
}

// ============================================================================
// NAVIGATION
// ============================================================================

class AppNavigationRail
    extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final String email;
  final String role;
  final ValueChanged<int> onSelected;

  const AppNavigationRail({
    super.key,
    required this.items,
    required this.selected,
    required this.email,
    required this.role,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin:
          const EdgeInsets.fromLTRB(
        14,
        8,
        0,
        14,
      ),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDDEBE6),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding:
                EdgeInsets.fromLTRB(
              10,
              9,
              10,
              18,
            ),
            child: Row(
              children: [
                BrandMark(
                  size: 42,
                  dark: true,
                ),
                SizedBox(width: 12),
                Text(
                  'CAMPUSCORE',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing:
                        .5,
                  ),
                ),
              ],
            ),
          ),
          UserPanel(
            email: email,
            role: role,
          ),
          const SizedBox(height: 13),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder:
                  (_, i) {
                final item =
                    items[i];

                final active =
                    i == selected;

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: ListTile(
                    selected:
                        active,
                    selectedTileColor:
                        kPrimary.withValues(
                      alpha: .10,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                    leading:
                        Icon(
                      active
                          ? item.filled
                          : item.outlined,
                      color:
                          active
                              ? kPrimary
                              : kMuted,
                    ),
                    title:
                        Text(
                      item.label,
                      style:
                          TextStyle(
                        fontWeight:
                            active
                                ? FontWeight
                                    .w800
                                : FontWeight
                                    .w500,
                        color:
                            active
                                ? kDark
                                : kText,
                      ),
                    ),
                    onTap: () =>
                        onSelected(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final String email;
  final String role;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.items,
    required this.selected,
    required this.email,
    required this.role,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  BrandMark(
                    size: 43,
                    dark: true,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'CAMPUSCORE',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: UserPanel(
                email: email,
                role: role,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount:
                    items.length,
                itemBuilder:
                    (_, i) {
                  final item =
                      items[i];

                  return ListTile(
                    selected:
                        i == selected,
                    leading: Icon(
                      i == selected
                          ? item.filled
                          : item.outlined,
                    ),
                    title:
                        Text(
                      item.label,
                    ),
                    onTap: () =>
                        onSelected(i),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(
                Icons.logout_rounded,
              ),
              title:
                  const Text(
                'Logout',
              ),
              onTap:
                  onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class UserPanel extends StatelessWidget {
  final String email;
  final String role;

  const UserPanel({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            kBackground,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                kPrimary,
            child:
                const Icon(
              Icons.person_rounded,
              color:
                  Colors.white,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  email,
                  maxLines:
                      1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        kMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final String role;
  final String email;

  const RoleBadge({
    super.key,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: kSoft,
          child: Icon(
            Icons.person_rounded,
            color: kPrimary,
          ),
        ),
        const SizedBox(width: 9),
        Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              email,
              style: const TextStyle(
                color: kMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// DASHBOARD
// ============================================================================

class DashboardPage extends StatefulWidget {
  final String role;

  const DashboardPage({
    super.key,
    required this.role,
  });

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {
  Map<String, dynamic>? data;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response =
          await api.get('/api/dashboard');

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          data =
              Map<String, dynamic>.from(
            jsonDecode(response.body),
          );
        });
      } else {
        setState(() {
          error =
              apiError(response);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error =
            'Could not load dashboard.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return CenterMessage(
        icon:
            Icons.cloud_off_rounded,
        title:
            'Dashboard unavailable',
        message:
            error!,
        actionText:
            'Retry',
        onAction:
            load,
      );
    }

    if (data == null) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: kPrimary,
        ),
      );
    }

    final gradeMap =
        (data!['grade_distribution']
                as Map?) ??
            {};

    final cards = [
      Metric(
        'Students',
        '${data!['students'] ?? 0}',
        Icons.people_rounded,
      ),
      Metric(
        'Attendance',
        '${data!['average_attendance'] ?? 0}%',
        Icons.fact_check_rounded,
      ),
      Metric(
        'Pending fees',
        currency(data!['pending_fees']),
        Icons.payments_rounded,
      ),
      Metric(
        'Pass rate',
        '${data!['pass_percentage'] ?? 0}%',
        Icons.verified_rounded,
      ),
    ];

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: load,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          22,
          14,
          22,
          30,
        ),
        children: [
          PageHeader(
            eyebrow:
                'CAMPUSCORE',
            title:
                widget.role == 'ADMIN'
                    ? 'Command center'
                    : widget.role == 'FACULTY'
                        ? 'Faculty dashboard'
                        : 'Student dashboard',
            subtitle:
                'One view of attendance, fees and academic performance.',
            action:
                IconButton(
              onPressed:
                  load,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          LayoutBuilder(
            builder:
                (context,
                    constraints) {
              final columns =
                  constraints.maxWidth >=
                          1100
                      ? 4
                      : constraints.maxWidth >=
                              650
                          ? 2
                          : 1;

              final width =
                  (constraints.maxWidth -
                          (columns -
                                  1) *
                              12) /
                      columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    cards.map(
                  (metric) {
                    return SizedBox(
                      width:
                          width,
                      child:
                          MetricCard(
                        metric:
                            metric,
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
          const SizedBox(
            height: 16,
          ),
          LayoutBuilder(
            builder:
                (context,
                    constraints) {
              final first =
                  GradeDistribution(
                values:
                    gradeMap,
              );

              final second =
                  DashboardInfo(
                role:
                    widget.role,
              );

              if (constraints
                      .maxWidth <
                  850) {
                return Column(
                  children: [
                    first,
                    const SizedBox(
                      height: 12,
                    ),
                    second,
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Expanded(
                    flex: 3,
                    child:
                        first,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    flex: 2,
                    child:
                        second,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class Metric {
  final String label;
  final String value;
  final IconData icon;

  const Metric(
    this.label,
    this.value,
    this.icon,
  );
}

class MetricCard
    extends StatelessWidget {
  final Metric metric;

  const MetricCard({
    super.key,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Row(
          children: [
            Container(
              width:
                  49,
              height:
                  49,
              decoration:
                  BoxDecoration(
                color:
                    kSoft,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  Icon(
                metric.icon,
                color:
                    kPrimary,
              ),
            ),
            const SizedBox(
              width:
                  13,
            ),
            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style:
                        const TextStyle(
                      color:
                          kMuted,
                      fontSize:
                          12,
                    ),
                  ),
                  const SizedBox(
                    height:
                        4,
                  ),
                  Text(
                    metric.value,
                    style:
                        const TextStyle(
                      color:
                          kDark,
                      fontSize:
                          23,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradeDistribution
    extends StatelessWidget {
  final Map values;

  const GradeDistribution({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    const grades = [
      'S',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
    ];

    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade distribution',
              style:
                  TextStyle(
                fontSize:
                    17,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height:
                  16,
            ),
            ...grades.map(
              (grade) {
                final count =
                    _asNumber(
                  values[
                      grade],
                ).toDouble();

                final total =
                    _asNumber(
                  values.values.fold<num>(
                    0,
                    (num a, dynamic b) =>
                        a + _asNumber(b),
                  ),
                ).toDouble();

                final ratio =
                    total ==
                            0
                        ? 0.0
                        : count /
                            total;

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom:
                        10,
                  ),
                  child:
                      Row(
                    children: [
                      SizedBox(
                        width:
                            30,
                        child:
                            Text(
                          grade,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                            LinearProgressIndicator(
                          value:
                              ratio,
                          minHeight:
                              9,
                          color:
                              kPrimary,
                          backgroundColor:
                              kSoft,
                        ),
                      ),
                      const SizedBox(
                        width:
                            10,
                      ),
                      SizedBox(
                        width:
                            26,
                        child:
                            Text(
                          '${count.toInt()}',
                          textAlign:
                              TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardInfo
    extends StatelessWidget {
  final String role;

  const DashboardInfo({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        role == 'ADMIN'
            ? 'Manage the entire academic lifecycle from one trusted record.'
            : role == 'FACULTY'
                ? 'Work only with your assigned subjects and classes.'
                : 'Track your attendance, fees, results, GPA and CGPA.';

    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          22,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons
                  .hub_rounded,
              color:
                  kPrimary,
              size:
                  32,
            ),
            const SizedBox(
              height:
                  14,
            ),
            const Text(
              'One record. Every module.',
              style:
                  TextStyle(
                fontSize:
                    18,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height:
                  8,
            ),
            Text(
              text,
              style:
                  const TextStyle(
                color:
                    kMuted,
                height:
                    1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STUDENTS
// ============================================================================

class StudentListPage
    extends StatefulWidget {
  final bool studentOnly;

  const StudentListPage({
    super.key,
    this.studentOnly = false,
  });

  @override
  State<StudentListPage> createState() =>
      _StudentListPageState();
}

class _StudentListPageState
    extends State<StudentListPage> {
  final search =
      TextEditingController();

  List<dynamic> students = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final q =
          search.text.trim();

      final path =
          q.isEmpty
              ? '/api/students'
              : '/api/students?q=${Uri.encodeQueryComponent(q)}';

      final response =
          await api.get(path);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          students =
              jsonDecode(
            response.body,
          ) as List<dynamic>;

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          error =
              apiError(response);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Could not load students.';
      });
    }
  }

  void openRecord(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentRecordPage(
          studentId: id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          PageHeader(
            eyebrow:
                'STUDENT MANAGEMENT',
            title:
                widget.studentOnly
                    ? 'My record'
                    : 'Students',
            subtitle:
                'The central student record connects profile, attendance, fees and academic performance.',
            action:
                widget.studentOnly
                    ? null
                    : FilledButton.icon(
                        onPressed:
                            () =>
                                showStudentDialog(
                          context,
                        ).then(
                          (_) =>
                              load(),
                        ),
                        icon:
                            const Icon(
                          Icons
                              .person_add_alt_1_rounded,
                        ),
                        label:
                            const Text(
                          'Add student',
                        ),
                      ),
          ),
          const SizedBox(
            height:
                16,
          ),
          if (!widget.studentOnly)
            Row(
              children: [
                Expanded(
                  child:
                      TextField(
                    controller:
                        search,
                    onSubmitted:
                        (_) =>
                            load(),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search name, roll number or email',
                      prefixIcon:
                          const Icon(
                        Icons.search_rounded,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed:
                            load,
                        icon:
                            const Icon(
                          Icons
                              .arrow_forward_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width:
                      8,
                ),
                IconButton(
                  onPressed:
                      load,
                  icon:
                      const Icon(
                    Icons
                        .refresh_rounded,
                  ),
                ),
              ],
            ),
          if (!widget.studentOnly)
            const SizedBox(
              height:
                  14,
            ),
          Expanded(
            child:
                loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              kPrimary,
                        ),
                      )
                    : error != null
                        ? CenterMessage(
                            icon:
                                Icons
                                    .people_outline_rounded,
                            title:
                                'Student data unavailable',
                            message:
                                error!,
                            actionText:
                                'Retry',
                            onAction:
                                load,
                          )
                        : students.isEmpty
                            ? const EmptyState(
                                icon:
                                    Icons.people_outline_rounded,
                                title:
                                    'No student records',
                                message:
                                    'No students match the current query.',
                              )
                            : Card(
                                child:
                                    ListView.separated(
                                  itemCount:
                                      students.length,
                                  separatorBuilder:
                                      (_, _) =>
                                          const Divider(
                                    height:
                                        1,
                                  ),
                                  itemBuilder:
                                      (_, i) {
                                    final student =
                                        Map<String,
                                            dynamic>.from(
                                      students[
                                          i],
                                    );

                                    final id =
                                        _int(
                                      student[
                                          'id'],
                                    );

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            18,
                                        vertical:
                                            8,
                                      ),
                                      leading:
                                          CircleAvatar(
                                        backgroundColor:
                                            kSoft,
                                        foregroundColor:
                                            kDark,
                                        child:
                                            Text(
                                          '${student['name'] ?? '?'}'
                                              .substring(
                                            0,
                                            1,
                                          )
                                              .toUpperCase(),
                                        ),
                                      ),
                                      title:
                                          Text(
                                        '${student['roll_no'] ?? '-'} • ${student['name'] ?? '-'}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                      subtitle:
                                          Text(
                                        'Semester ${student['semester'] ?? '-'} • Section ${student['section'] ?? '-'} • ${student['email'] ?? '-'}',
                                      ),
                                      trailing:
                                          Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          StatusChip(
                                            text:
                                                '${student['status'] ?? 'ACTIVE'}',
                                            good:
                                                '${student['status']}'.toUpperCase() ==
                                                    'ACTIVE',
                                          ),
                                          const SizedBox(
                                            width:
                                                10,
                                          ),
                                          const Icon(
                                            Icons
                                                .arrow_forward_ios_rounded,
                                            size:
                                                15,
                                          ),
                                        ],
                                      ),
                                      onTap:
                                          id == null
                                              ? null
                                              : () =>
                                                  openRecord(
                                                id,
                                              ),
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CENTRAL STUDENT RECORD
// ============================================================================

class StudentRecordPage
    extends StatefulWidget {
  final int studentId;

  const StudentRecordPage({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentRecordPage> createState() =>
      _StudentRecordPageState();
}

class _StudentRecordPageState
    extends State<StudentRecordPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? student;
  List<dynamic> results = [];
  List<dynamic> attendance = [];
  List<dynamic> fees = [];
  List<dynamic> payments = [];

  double cgpa = 0;
  double? gpa;
  int? selectedSemester;

  bool loading = true;
  String? error;

  late TabController tabs;

  @override
  void initState() {
    super.initState();

    tabs = TabController(
      length: 5,
      vsync: this,
    );

    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final responseList =
          await Future.wait([
        api.get(
          '/api/students/${widget.studentId}',
        ),
        api.get(
          '/api/attendance?student_id=${widget.studentId}',
        ),
        api.get(
          '/api/fees/student/${widget.studentId}',
        ),
      ]);

      if (!mounted) return;

      if (responseList[0].statusCode !=
          200) {
        setState(() {
          loading = false;
          error =
              apiError(
            responseList[0],
          );
        });

        return;
      }

      final detail =
          jsonDecode(
        responseList[0].body,
      ) as Map<String, dynamic>;

      final att =
          responseList[1].statusCode ==
                  200
              ? jsonDecode(
                  responseList[1].body,
                ) as List<dynamic>
              : <dynamic>[];

      final fee =
          responseList[2].statusCode ==
                  200
              ? jsonDecode(
                  responseList[2].body,
                ) as List<dynamic>
              : <dynamic>[];

      setState(() {
        student =
            Map<String, dynamic>.from(
          detail['student'] ?? {},
        );

        results =
            (detail['results']
                    as List<dynamic>?) ??
                [];

        attendance =
            att;

        fees =
            fee;

        payments = [];

        cgpa =
            _asNumber(
          detail['cgpa'],
        ).toDouble();

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Could not load the student record.';
      });
    }
  }

  Future<void> loadGpa(int semester) async {
    final response =
        await api.get(
      '/api/gpa/${widget.studentId}?semester=$semester',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      setState(() {
        selectedSemester =
            semester;
        gpa =
            _asNumber(
          data['gpa'],
        ).toDouble();
      });
    }
  }

  double get attendancePercent {
    if (attendance.isEmpty) {
      return 0;
    }

    final present =
        attendance.where(
      (item) =>
          '${item['status'] ?? ''}'
              .toUpperCase() ==
          'PRESENT',
    ).length;

    return present /
            attendance.length *
            100;
  }

  double get due {
    return fees.fold(
      0.0,
      (sum, item) =>
          sum +
          _asNumber(
            item['amount_due'],
          ),
    );
  }

  double get paid {
    return fees.fold(
      0.0,
      (sum, item) =>
          sum +
          _asNumber(
            item['amount_paid'],
          ),
    );
  }

  double get outstanding =>
      (due - paid)
          .clamp(
            0,
            double.infinity,
          )
          .toDouble();

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(
            color: kPrimary,
          ),
        ),
      );
    }

    if (error != null ||
        student == null) {
      return Scaffold(
        appBar:
            AppBar(
          title:
              const Text(
            'Student record',
          ),
        ),
        body:
            CenterMessage(
          icon:
              Icons.person_off_outlined,
          title:
              'Record unavailable',
          message:
              error ??
              'Student not found.',
          actionText:
              'Retry',
          onAction:
              load,
        ),
      );
    }

    final name =
        '${student!['name'] ?? 'Student'}';

    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(
          onPressed:
              () =>
                  Navigator.pop(
            context,
          ),
          icon:
              const Icon(
            Icons
                .arrow_back_rounded,
          ),
        ),
        title:
            const Text(
          'Central Student Record',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                load,
            icon:
                const Icon(
              Icons
                  .refresh_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          22,
          8,
          22,
          30,
        ),
        children: [
          Card(
            child:
                Padding(
              padding:
                  const EdgeInsets.all(
                22,
              ),
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius:
                            34,
                        backgroundColor:
                            kSoft,
                        foregroundColor:
                            kDark,
                        child:
                            Text(
                          name
                              .substring(
                            0,
                            1,
                          )
                              .toUpperCase(),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w900,
                            fontSize:
                                25,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width:
                            14,
                      ),
                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style:
                                  const TextStyle(
                                fontSize:
                                    25,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  4,
                            ),
                            Text(
                              '${student!['roll_no'] ?? '-'} • Semester ${student!['semester'] ?? '-'} • Section ${student!['section'] ?? '-'}',
                              style:
                                  const TextStyle(
                                color:
                                    kMuted,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  4,
                            ),
                            Text(
                              '${student!['email'] ?? '-'}',
                              style:
                                  const TextStyle(
                                color:
                                    kMuted,
                                fontSize:
                                    12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        text:
                            '${student!['status'] ?? 'ACTIVE'}',
                        good:
                            '${student!['status'] ?? ''}'.toUpperCase() ==
                                'ACTIVE',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height:
                14,
          ),
          LayoutBuilder(
            builder:
                (
              context,
              constraints,
            ) {
              final stats = [
                RecordMetric(
                  'Attendance',
                  '${attendancePercent.toStringAsFixed(1)}%',
                  Icons
                      .fact_check_rounded,
                  warning:
                      attendancePercent <
                          75,
                ),
                RecordMetric(
                  'Outstanding',
                  currency(
                    outstanding,
                  ),
                  Icons
                      .payments_rounded,
                  warning:
                      outstanding >
                          0,
                ),
                RecordMetric(
                  'CGPA',
                  cgpa
                      .toStringAsFixed(
                    2,
                  ),
                  Icons
                      .school_rounded,
                ),
                RecordMetric(
                  'Subjects',
                  '${results.length}',
                  Icons
                      .menu_book_rounded,
                ),
              ];

              final columns =
                  constraints.maxWidth >=
                          1050
                      ? 4
                      : constraints.maxWidth >=
                              650
                          ? 2
                          : 1;

              final width =
                  (constraints.maxWidth -
                          (columns -
                                  1) *
                              12) /
                      columns;

              return Wrap(
                spacing:
                    12,
                runSpacing:
                    12,
                children:
                    stats.map(
                  (
                    item,
                  ) =>
                      SizedBox(
                    width:
                        width,
                    child:
                        RecordMetricCard(
                      metric:
                          item,
                    ),
                  ),
                ).toList(),
              );
            },
          ),
          const SizedBox(
            height:
                16,
          ),
          Card(
            clipBehavior:
                Clip.antiAlias,
            child:
                Column(
              children: [
                TabBar(
                  controller:
                      tabs,
                  isScrollable:
                      true,
                  tabs: const [
                    Tab(
                      text:
                          'Overview',
                    ),
                    Tab(
                      text:
                          'Attendance',
                    ),
                    Tab(
                      text:
                          'Fees',
                    ),
                    Tab(
                      text:
                          'Results',
                    ),
                    Tab(
                      text:
                          'Payments',
                    ),
                  ],
                ),
                SizedBox(
                  height:
                      540,
                  child:
                      TabBarView(
                    controller:
                        tabs,
                    children: [
                      StudentOverviewTab(
                        student:
                            student!,
                        attendance:
                            attendancePercent,
                        outstanding:
                            outstanding,
                        cgpa:
                            cgpa,
                      ),
                      StudentAttendanceTab(
                        rows:
                            attendance,
                      ),
                      StudentFeesTab(
                        rows:
                            fees,
                      ),
                      StudentResultsTab(
                        rows:
                            results,
                        cgpa:
                            cgpa,
                        selectedSemester:
                            selectedSemester,
                        gpa:
                            gpa,
                        onSemester:
                            loadGpa,
                      ),
                      StudentPaymentsTab(
                        rows:
                            payments,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecordMetric {
  final String label;
  final String value;
  final IconData icon;
  final bool warning;

  const RecordMetric(
    this.label,
    this.value,
    this.icon, {
    this.warning = false,
  });
}

class RecordMetricCard
    extends StatelessWidget {
  final RecordMetric metric;

  const RecordMetricCard({
    super.key,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        metric.warning
            ? Colors.orange
            : kPrimary;

    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child:
            Row(
          children: [
            Container(
              width:
                  45,
              height:
                  45,
              decoration:
                  BoxDecoration(
                color:
                    color.withValues(
                  alpha:
                      .10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  Icon(
                metric.icon,
                color:
                    color,
              ),
            ),
            const SizedBox(
              width:
                  12,
            ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style:
                      const TextStyle(
                    color:
                        kMuted,
                    fontSize:
                        11,
                  ),
                ),
                const SizedBox(
                  height:
                      3,
                ),
                Text(
                  metric.value,
                  style:
                      const TextStyle(
                    fontSize:
                        20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentOverviewTab
    extends StatelessWidget {
  final Map<String, dynamic> student;
  final double attendance;
  final double outstanding;
  final double cgpa;

  const StudentOverviewTab({
    super.key,
    required this.student,
    required this.attendance,
    required this.outstanding,
    required this.cgpa,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),
      children: [
        const Text(
          'Profile',
          style:
              TextStyle(
            fontSize:
                17,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        const SizedBox(
          height:
              8,
        ),
        Card(
          child:
              Column(
            children: [
              InfoRow(
                label:
                    'Name',
                value:
                    '${student['name'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Roll number',
                value:
                    '${student['roll_no'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Email',
                value:
                    '${student['email'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Phone',
                value:
                    '${student['phone'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Semester',
                value:
                    '${student['semester'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Section',
                value:
                    '${student['section'] ?? '-'}',
              ),
              InfoRow(
                label:
                    'Department ID',
                value:
                    '${student['department_id'] ?? '-'}',
              ),
            ],
          ),
        ),
        const SizedBox(
          height:
              15,
        ),
        if (attendance <
            75)
          const AlertPanel(
            title:
                'Low attendance',
            message:
                'Attendance is below the 75% monitoring threshold.',
            icon:
                Icons
                    .warning_amber_rounded,
          ),
        if (outstanding >
            0)
          const Padding(
            padding:
                EdgeInsets.only(
              top:
                  10,
            ),
            child:
                AlertPanel(
              title:
                  'Outstanding fee balance',
              message:
                  'This student has an unpaid fee balance.',
              icon:
                  Icons
                      .payments_outlined,
            ),
          ),
        const SizedBox(
          height:
              12,
        ),
        SnapshotRow(
          firstLabel:
              'Attendance',
          firstValue:
              '${attendance.toStringAsFixed(1)}%',
          secondLabel:
              'CGPA',
          secondValue:
              cgpa.toStringAsFixed(
            2,
          ),
        ),
      ],
    );
  }
}

class StudentAttendanceTab
    extends StatelessWidget {
  final List<dynamic> rows;

  const StudentAttendanceTab({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final present =
        rows.where(
      (item) =>
          '${item['status'] ?? ''}'
              .toUpperCase() ==
          'PRESENT',
    ).length;

    final percentage =
        rows.isEmpty
            ? 0.0
            : present /
                rows.length *
                100;

    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),
      children: [
        SnapshotRow(
          firstLabel:
              'Attendance %',
          firstValue:
              '${percentage.toStringAsFixed(1)}%',
          secondLabel:
              'Present',
          secondValue:
              '$present',
        ),
        const SizedBox(
          height:
              16,
        ),
        if (rows.isEmpty)
          const EmptyState(
            icon:
                Icons
                    .fact_check_outlined,
            title:
                'No attendance records',
            message:
                'Attendance will appear here once recorded.',
          )
        else
          ...rows.map(
            (item) {
              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom:
                      8,
                ),
                child:
                    ListTile(
                  leading:
                      CircleAvatar(
                    backgroundColor:
                        kSoft,
                    child:
                        Icon(
                      '${item['status'] ?? ''}'
                                  .toUpperCase() ==
                              'PRESENT'
                          ? Icons
                              .check_rounded
                          : Icons
                              .close_rounded,
                      color:
                          kDark,
                    ),
                  ),
                  title:
                      Text(
                    'Subject #${item['subject_id'] ?? '-'}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle:
                      Text(
                    '${item['date'] ?? '-'}',
                  ),
                  trailing:
                      StatusChip(
                    text:
                        '${item['status'] ?? '-'}',
                    good:
                        '${item['status'] ?? ''}'.toUpperCase() ==
                            'PRESENT',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class StudentFeesTab
    extends StatelessWidget {
  final List<dynamic> rows;

  const StudentFeesTab({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final due =
        rows.fold(
      0.0,
      (a,
          b) =>
          a +
          _asNumber(
            b['amount_due'],
          ),
    );

    final paid =
        rows.fold(
      0.0,
      (a,
          b) =>
          a +
          _asNumber(
            b['amount_paid'],
          ),
    );

    final balance =
        (due - paid)
            .clamp(
              0,
              double.infinity,
            )
            .toDouble();

    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),
      children: [
        SnapshotRow(
          firstLabel:
              'Due',
          firstValue:
              currency(due),
          secondLabel:
              'Paid',
          secondValue:
              currency(paid),
        ),
        const SizedBox(
          height:
              10,
        ),
        SnapshotTile(
          label:
              'Outstanding',
          value:
              currency(balance),
          icon:
              Icons
                  .account_balance_wallet_rounded,
        ),
        const SizedBox(
          height:
              16,
        ),
        ...rows.map(
          (item) {
            return Card(
              margin:
                  const EdgeInsets.only(
                bottom:
                    8,
              ),
              child:
                  ListTile(
                leading:
                    const Icon(
                  Icons
                      .receipt_long_rounded,
                  color:
                      kPrimary,
                ),
                title:
                    Text(
                  'Fee #${item['id'] ?? '-'}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                subtitle:
                    Text(
                  'Due ${currency(item['amount_due'])} • Paid ${currency(item['amount_paid'])}',
                ),
                trailing:
                    StatusChip(
                  text:
                      '${item['status'] ?? '-'}',
                  good:
                      '${item['status'] ?? ''}'.toUpperCase() ==
                          'PAID',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class StudentResultsTab
    extends StatelessWidget {
  final List<dynamic> rows;
  final double cgpa;
  final int? selectedSemester;
  final double? gpa;
  final Future<void> Function(int) onSemester;

  const StudentResultsTab({
    super.key,
    required this.rows,
    required this.cgpa,
    required this.selectedSemester,
    required this.gpa,
    required this.onSemester,
  });

  @override
  Widget build(BuildContext context) {
    final semesters =
        rows
            .map(
              (e) =>
                  _int(
                    e['semester'],
                  ),
            )
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();

    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child:
                  SnapshotTile(
                label:
                    'CGPA',
                value:
                    cgpa.toStringAsFixed(
                  2,
                ),
                icon:
                    Icons
                        .school_rounded,
              ),
            ),
            if (semesters.isNotEmpty) ...[
              const SizedBox(
                width:
                    10,
              ),
              Expanded(
                child:
                    DropdownButtonFormField<int>(
                  initialValue:
                      semesters.contains(
                            selectedSemester,
                          )
                          ? selectedSemester
                          : null,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Semester GPA',
                  ),
                  items:
                      semesters.map(
                    (semester) =>
                        DropdownMenuItem<
                            int>(
                      value:
                          semester,
                      child:
                          Text(
                        'Semester $semester',
                      ),
                    ),
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      onSemester(
                        value,
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        if (gpa != null) ...[
          const SizedBox(
            height:
                10,
          ),
          SnapshotTile(
            label:
                'Selected semester GPA',
            value:
                gpa!.toStringAsFixed(
              2,
            ),
            icon:
                Icons
                    .trending_up_rounded,
          ),
        ],
        const SizedBox(
          height:
              16,
        ),
        if (rows.isEmpty)
          const EmptyState(
            icon:
                Icons
                    .school_outlined,
            title:
                'No results',
            message:
                'Calculated results will appear here.',
          )
        else
          ...rows.map(
            (item) {
              final grade =
                  '${item['grade'] ?? '-'}';

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom:
                      8,
                ),
                child:
                    ListTile(
                  leading:
                      CircleAvatar(
                    backgroundColor:
                        grade ==
                                'F'
                            ? Colors
                                .red
                                .withValues(
                              alpha:
                                  .10,
                            )
                            : kSoft,
                    foregroundColor:
                        grade ==
                                'F'
                            ? Colors
                                .red
                            : kDark,
                    child:
                        Text(
                      grade,
                    ),
                  ),
                  title:
                      Text(
                    '${item['subject_code'] ?? '-'} • ${item['subject_name'] ?? '-'}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  subtitle:
                      Text(
                    'Score ${item['score'] ?? '-'} • Grade point ${item['grade_point'] ?? '-'} • Semester ${item['semester'] ?? '-'}',
                  ),
                  trailing:
                      StatusChip(
                    text:
                        '${item['status'] ?? grade}',
                    good:
                        grade.toUpperCase() !=
                            'F',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class StudentPaymentsTab
    extends StatelessWidget {
  final List<dynamic> rows;

  const StudentPaymentsTab({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const EmptyState(
        icon:
            Icons
                .receipt_long_outlined,
        title:
            'No payments',
        message:
            'Payment history is empty.',
      );
    }

    return ListView.separated(
      padding:
          const EdgeInsets.all(
        20,
      ),
      itemCount:
          rows.length,
      separatorBuilder:
          (_, _) =>
              const Divider(
        height:
            1,
      ),
      itemBuilder:
          (_, i) {
            final row =
                Map<String,
                    dynamic>.from(
              rows[i],
            );

            return ListTile(
              leading:
                  const CircleAvatar(
                backgroundColor:
                    kSoft,
                child:
                    Icon(
                  Icons
                      .payments_rounded,
                  color:
                      kDark,
                ),
              ),
              title:
                  Text(
                currency(
                  row['amount'],
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              subtitle:
                  Text(
                '${row['paid_on'] ?? '-'} • Ref ${row['reference_no'] ?? '-'}',
              ),
            );
          },
    );
  }
}

// ============================================================================
// FACULTY
// ============================================================================

class FacultyPage
    extends StatefulWidget {
  const FacultyPage({super.key});

  @override
  State<FacultyPage> createState() =>
      _FacultyPageState();
}

class _FacultyPageState
    extends State<FacultyPage> {
  List<dynamic> faculty = [];
  List<dynamic> departments = [];
  List<dynamic> subjects = [];
  List<dynamic> sections = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final responses =
          await Future.wait([
        api.get('/api/faculty'),
        api.get('/api/departments'),
        api.get('/api/subjects'),
        api.get('/api/sections'),
      ]);

      if (!mounted) return;

      if (responses.first.statusCode !=
          200) {
        setState(() {
          error =
              apiError(responses.first);
          loading = false;
        });

        return;
      }

      setState(() {
        faculty =
            jsonDecode(
          responses[0].body,
        ) as List<dynamic>;

        departments =
            responses[1].statusCode ==
                    200
                ? jsonDecode(
                    responses[1].body,
                  ) as List<dynamic>
                : [];

        subjects =
            responses[2].statusCode ==
                    200
                ? jsonDecode(
                    responses[2].body,
                  ) as List<dynamic>
                : [];

        sections =
            responses[3].statusCode ==
                    200
                ? jsonDecode(
                    responses[3].body,
                  ) as List<dynamic>
                : [];

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Could not load faculty.';
      });
    }
  }

  Future<void> assignmentDialog(
    int facultyId,
  ) async {
    int? subjectId;
    int? sectionId;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder:
              (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title:
                  const Text(
                'Assign subject and section',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              content:
                  SizedBox(
                width:
                    500,
                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue:
                          subjectId,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Subject',
                      ),
                      items:
                          subjects
                              .map(
                                (
                                  item,
                                ) =>
                                    DropdownMenuItem<
                                        int>(
                                  value:
                                      _int(
                                    item[
                                        'id'],
                                  ),
                                  child:
                                      Text(
                                    '${item['code'] ?? ''} • ${item['name'] ?? ''}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (
                            value,
                          ) =>
                              setDialogState(
                        () =>
                            subjectId =
                                value,
                      ),
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                    DropdownButtonFormField<int>(
                      initialValue:
                          sectionId,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Section',
                      ),
                      items:
                          sections
                              .map(
                                (
                                  item,
                                ) =>
                                    DropdownMenuItem<
                                        int>(
                                  value:
                                      _int(
                                    item[
                                        'id'],
                                  ),
                                  child:
                                      Text(
                                    '${item['name'] ?? ''} • Semester ${item['semester'] ?? '-'}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (
                            value,
                          ) =>
                              setDialogState(
                        () =>
                            sectionId =
                                value,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      () =>
                          Navigator.pop(
                    context,
                  ),
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed:
                      subjectId ==
                                  null ||
                              sectionId ==
                                  null
                          ? null
                          : () async {
                              final response =
                                  await api.post(
                                '/api/faculty/assign?faculty_id=$facultyId&subject_id=$subjectId&section_id=$sectionId',
                              );

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.pop(
                                context,
                              );

                              ScaffoldMessenger
                                      .of(
                                context,
                              )
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(
                                    response.statusCode <
                                            300
                                        ? 'Assignment saved.'
                                        : apiError(
                                            response,
                                          ),
                                  ),
                                ),
                              );
                            },
                  child:
                      const Text(
                    'Assign',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          PageHeader(
            eyebrow:
                'FACULTY',
            title:
                'Faculty',
            subtitle:
                'Profiles, academic assignments and section ownership.',
            action:
                IconButton(
              onPressed:
                  load,
              icon:
                  const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ),
          const SizedBox(
            height:
                18,
          ),
          Expanded(
            child:
                loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              kPrimary,
                        ),
                      )
                    : error != null
                        ? CenterMessage(
                            icon:
                                Icons.badge_outlined,
                            title:
                                'Faculty unavailable',
                            message:
                                error!,
                            actionText:
                                'Retry',
                            onAction:
                                load,
                          )
                        : Card(
                            child:
                                ListView.separated(
                              itemCount:
                                  faculty.length,
                              separatorBuilder:
                                  (_, _) =>
                                      const Divider(
                                height:
                                    1,
                              ),
                              itemBuilder:
                                  (_, i) {
                                final f =
                                    Map<String,
                                        dynamic>.from(
                                  faculty[
                                      i],
                                );

                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        18,
                                    vertical:
                                        7,
                                  ),
                                  leading:
                                      const CircleAvatar(
                                    backgroundColor:
                                        kSoft,
                                    child:
                                        Icon(
                                      Icons
                                          .badge_rounded,
                                      color:
                                          kDark,
                                    ),
                                  ),
                                  title:
                                      Text(
                                    '${f['name'] ?? f['email'] ?? 'Faculty'}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                  subtitle:
                                      Text(
                                    '${f['email'] ?? '-'} • Department ${f['department_id'] ?? '-'}',
                                  ),
                                  trailing:
                                      OutlinedButton(
                                    onPressed:
                                        () =>
                                            assignmentDialog(
                                      _int(
                                            f['id'],
                                          ) ??
                                          0,
                                    ),
                                    child:
                                        const Text(
                                      'Assign',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACADEMIC SETUP
// ============================================================================

class AcademicSetupPage
    extends StatefulWidget {
  const AcademicSetupPage({super.key});

  @override
  State<AcademicSetupPage> createState() =>
      _AcademicSetupPageState();
}

class _AcademicSetupPageState
    extends State<AcademicSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController tabs;

  @override
  void initState() {
    super.initState();

    tabs = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          const PageHeader(
            eyebrow:
                'ACADEMIC SETUP',
            title:
                'Departments, sections & subjects',
            subtitle:
                'Configure the academic structure used by the ERP.',
          ),
          const SizedBox(
            height:
                18,
          ),
          Card(
            clipBehavior:
                Clip.antiAlias,
            child:
                Column(
              children: [
                TabBar(
                  controller:
                      tabs,
                  tabs: const [
                    Tab(
                      text:
                          'Departments',
                    ),
                    Tab(
                      text:
                          'Sections',
                    ),
                    Tab(
                      text:
                          'Subjects',
                    ),
                  ],
                ),
                Expanded(
                  child:
                      TabBarView(
                    controller:
                        tabs,
                    children: const [
                      DepartmentManager(),
                      SectionManager(),
                      SubjectManager(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DepartmentManager
    extends StatefulWidget {
  const DepartmentManager({
    super.key,
  });

  @override
  State<DepartmentManager>
      createState() =>
          _DepartmentManagerState();
}

class _DepartmentManagerState
    extends State<DepartmentManager> {
  List<dynamic> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response =
        await api.get(
      '/api/departments',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        rows =
            jsonDecode(
          response.body,
        ) as List<dynamic>;

        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> add() async {
    final name =
        TextEditingController();

    final code =
        TextEditingController();

    final result =
        await showDialog<bool>(
      context: context,
      builder:
          (_) =>
              AlertDialog(
        title:
            const Text(
          'Add department',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        content:
            SizedBox(
          width:
              430,
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    name,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Department name',
                ),
              ),
              const SizedBox(
                height:
                    12,
              ),
              TextField(
                controller:
                    code,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Code',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              false,
            ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed:
                () {
              Navigator.pop(context, false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Departments are managed by the backend master-data layer.'),
                ),
              );
            },
            child:
                const Text(
              'Create',
            ),
          ),
        ],
      ),
    );

    name.dispose();
    code.dispose();

    if (result == true) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.all(
        18,
      ),
      child:
          Column(
        children: [
          Align(
            alignment:
                Alignment.centerRight,
            child:
                FilledButton.icon(
              onPressed:
                  add,
              icon:
                  const Icon(
                Icons.add_rounded,
              ),
              label:
                  const Text(
                'Department',
              ),
            ),
          ),
          const SizedBox(
            height:
                12,
          ),
          Expanded(
            child:
                loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              kPrimary,
                        ),
                      )
                    : ListView.separated(
                        itemCount:
                            rows.length,
                        separatorBuilder:
                            (_, _) =>
                                const Divider(
                          height:
                              1,
                        ),
                        itemBuilder:
                            (_, i) {
                          final row =
                              rows[i];

                          return ListTile(
                            leading:
                                const CircleAvatar(
                              backgroundColor:
                                  kSoft,
                              child:
                                  Icon(
                                Icons
                                    .apartment_rounded,
                                color:
                                    kDark,
                              ),
                            ),
                            title:
                                Text(
                              '${row['name'] ?? '-'}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            subtitle:
                                Text(
                              'Code: ${row['code'] ?? '-'} • ID: ${row['id'] ?? '-'}',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class SectionManager extends StatefulWidget {
  const SectionManager({super.key});

  @override
  State<SectionManager> createState() => _SectionManagerState();
}

class _SectionManagerState extends State<SectionManager> {
  List<dynamic> rows = [];
  List<dynamic> departments = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final responses = await Future.wait([
        api.get('/api/sections'),
        api.get('/api/departments'),
      ]);

      if (!mounted) return;

      if (responses[0].statusCode != 200) {
        setState(() {
          loading = false;
          error = apiError(responses[0]);
        });
        return;
      }

      setState(() {
        rows = jsonDecode(responses[0].body) as List<dynamic>;
        departments = responses[1].statusCode == 200
            ? jsonDecode(responses[1].body) as List<dynamic>
            : <dynamic>[];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load sections.';
      });
    }
  }

  String departmentName(int? id) {
    for (final item in departments) {
      if (_int(item['id']) == id) {
        return '${item['name'] ?? '-'}';
      }
    }
    return id == null ? 'Department -' : 'Department $id';
  }

  Future<void> showAddInfo() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Section management',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'The current FastAPI backend exposes section listing only. '
          'There is no POST /api/sections endpoint, so this screen does not '
          'pretend to create records that the server cannot save.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: PageHeader(
                  eyebrow: 'ACADEMIC SETUP',
                  title: 'Sections',
                  subtitle: 'View sections supplied by the ERP master-data layer.',
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: load,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: showAddInfo,
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('About section creation'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : error != null
                    ? CenterMessage(
                        icon: Icons.groups_outlined,
                        title: 'Section data unavailable',
                        message: error!,
                        actionText: 'Retry',
                        onAction: load,
                      )
                    : rows.isEmpty
                        ? const EmptyState(
                            icon: Icons.groups_outlined,
                            title: 'No sections found',
                            message: 'No sections are currently available in the backend.',
                          )
                        : Card(
                            child: ListView.separated(
                              itemCount: rows.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final row = Map<String, dynamic>.from(rows[i]);
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: kSoft,
                                    child: Icon(Icons.groups_rounded, color: kDark),
                                  ),
                                  title: Text(
                                    '${row['name'] ?? '-'}',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  subtitle: Text(
                                    '${departmentName(_int(row['department_id']))} • '
                                    'Semester ${row['semester'] ?? '-'} • '
                                    'Academic year ${row['academic_year'] ?? '-'}',
                                  ),
                                  trailing: Text(
                                    'ID ${row['id'] ?? '-'}',
                                    style: const TextStyle(color: kMuted),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class SubjectManager extends StatefulWidget {
  const SubjectManager({super.key});

  @override
  State<SubjectManager> createState() => _SubjectManagerState();
}

class _SubjectManagerState extends State<SubjectManager> {
  List<dynamic> rows = [];
  List<dynamic> departments = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final responses = await Future.wait([
        api.get('/api/subjects'),
        api.get('/api/departments'),
      ]);

      if (!mounted) return;

      if (responses[0].statusCode != 200) {
        setState(() {
          loading = false;
          error = apiError(responses[0]);
        });
        return;
      }

      setState(() {
        rows = jsonDecode(responses[0].body) as List<dynamic>;
        departments = responses[1].statusCode == 200
            ? jsonDecode(responses[1].body) as List<dynamic>
            : <dynamic>[];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load subjects.';
      });
    }
  }

  String departmentName(int? id) {
    for (final item in departments) {
      if (_int(item['id']) == id) {
        return '${item['name'] ?? '-'}';
      }
    }
    return id == null ? 'Department -' : 'Department $id';
  }

  Future<void> showAddInfo() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Subject management',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'The current FastAPI backend exposes subject listing only. '
          'There is no POST /api/subjects endpoint, so new subjects are '
          'managed through the backend seed/database layer.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: PageHeader(
                  eyebrow: 'ACADEMIC SETUP',
                  title: 'Subjects',
                  subtitle: 'View subjects supplied by the ERP master-data layer.',
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: load,
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: showAddInfo,
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('About subject creation'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : error != null
                    ? CenterMessage(
                        icon: Icons.menu_book_outlined,
                        title: 'Subject data unavailable',
                        message: error!,
                        actionText: 'Retry',
                        onAction: load,
                      )
                    : rows.isEmpty
                        ? const EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'No subjects found',
                            message: 'No subjects are currently available in the backend.',
                          )
                        : Card(
                            child: ListView.separated(
                              itemCount: rows.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final row = Map<String, dynamic>.from(rows[i]);
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: kSoft,
                                    child: Icon(Icons.menu_book_rounded, color: kDark),
                                  ),
                                  title: Text(
                                    '${row['code'] ?? '-'} • ${row['name'] ?? '-'}',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  subtitle: Text(
                                    '${departmentName(_int(row['department_id']))} • '
                                    'Semester ${row['semester'] ?? '-'} • '
                                    'Credits ${row['credits'] ?? '-'}',
                                  ),
                                  trailing: Text(
                                    'ID ${row['id'] ?? '-'}',
                                    style: const TextStyle(color: kMuted),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ATTENDANCE
// ============================================================================

class AttendancePage
    extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState
    extends State<AttendancePage> {
  List<dynamic> rows = [];
  List<dynamic> students = [];
  List<dynamic> subjects = [];

  int? studentId;
  int? subjectId;

  String status = 'PRESENT';

  DateTime selectedDate =
      DateTime.now();

  bool loading = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final responses =
          await Future.wait([
        api.get('/api/attendance'),
        api.get('/api/students'),
        api.get('/api/subjects'),
      ]);

      if (!mounted) return;

      if (responses[0].statusCode !=
          200) {
        setState(() {
          error =
              apiError(
            responses[0],
          );
          loading = false;
        });

        return;
      }

      setState(() {
        rows =
            jsonDecode(
          responses[0].body,
        ) as List<dynamic>;

        students =
            responses[1].statusCode ==
                    200
                ? jsonDecode(
                    responses[1].body,
                  ) as List<dynamic>
                : [];

        subjects =
            responses[2].statusCode ==
                    200
                ? jsonDecode(
                    responses[2].body,
                  ) as List<dynamic>
                : [];

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'Could not load attendance.';
      });
    }
  }

  Future<void> save() async {
    if (studentId == null ||
        subjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Select student and subject.',
          ),
        ),
      );

      return;
    }

    setState(() =>
        saving = true);

    final response =
        await api.post(
      '/api/attendance/bulk',
      body: [
        {
          'student_id':
              studentId,
          'subject_id':
              subjectId,
          'date':
              selectedDate
                  .toIso8601String()
                  .substring(
                    0,
                    10,
                  ),
          'status':
              status,
        },
      ],
    );

    if (!mounted) return;

    setState(() =>
        saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode <
                  300
              ? 'Attendance saved.'
              : apiError(
                  response,
                ),
        ),
      ),
    );

    if (response.statusCode <
        300) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              kPrimary,
        ),
      );
    }

    if (error != null) {
      return CenterMessage(
        icon:
            Icons.fact_check_outlined,
        title:
            'Attendance unavailable',
        message:
            error!,
        actionText:
            'Retry',
        onAction:
            load,
      );
    }

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          const PageHeader(
            eyebrow:
                'OPERATIONS',
            title:
                'Attendance',
            subtitle:
                'Daily subject-wise marking with duplicate protection and percentage tracking.',
          ),
          const SizedBox(
            height:
                18,
          ),
          Card(
            child:
                Padding(
              padding:
                  const EdgeInsets.all(
                17,
              ),
              child:
                  LayoutBuilder(
                builder:
                    (
                  context,
                  constraints,
                ) {
                  final compact =
                      constraints
                              .maxWidth <
                          850;

                  final studentField =
                      DropdownButtonFormField<int>(
                    initialValue:
                        studentId,
                    isExpanded:
                        true,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Student',
                    ),
                    items:
                        students.map(
                      (item) =>
                          DropdownMenuItem<int>(
                        value:
                            _int(
                          item[
                              'id'],
                        ),
                        child:
                            Text(
                          '${item['roll_no'] ?? ''} • ${item['name'] ?? ''}',
                        ),
                      ),
                    ).toList(),
                    onChanged:
                        (value) =>
                            setState(
                      () =>
                          studentId =
                              value,
                    ),
                  );

                  final subjectField =
                      DropdownButtonFormField<int>(
                    initialValue:
                        subjectId,
                    isExpanded:
                        true,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Subject',
                    ),
                    items:
                        subjects.map(
                      (item) =>
                          DropdownMenuItem<int>(
                        value:
                            _int(
                          item[
                              'id'],
                        ),
                        child:
                            Text(
                          '${item['code'] ?? ''} • ${item['name'] ?? ''}',
                        ),
                      ),
                    ).toList(),
                    onChanged:
                        (value) =>
                            setState(
                      () =>
                          subjectId =
                              value,
                    ),
                  );

                  final statusField =
                      DropdownButtonFormField<String>(
                    initialValue:
                        status,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Status',
                    ),
                    items:
                        const [
                      DropdownMenuItem(
                        value:
                            'PRESENT',
                        child:
                            Text(
                          'Present',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'ABSENT',
                        child:
                            Text(
                          'Absent',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'LATE',
                        child:
                            Text(
                          'Late',
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value !=
                          null) {
                        setState(
                          () =>
                              status =
                                  value,
                        );
                      }
                    },
                  );

                  final date =
                      OutlinedButton.icon(
                    onPressed:
                        () async {
                      final picked =
                          await showDatePicker(
                        context:
                            context,
                        initialDate:
                            selectedDate,
                        firstDate:
                            DateTime(
                          2020,
                        ),
                        lastDate:
                            DateTime(
                          2100,
                        ),
                      );

                      if (picked !=
                          null) {
                        setState(
                          () =>
                              selectedDate =
                                  picked,
                        );
                      }
                    },
                    icon:
                        const Icon(
                      Icons
                          .calendar_month_outlined,
                    ),
                    label:
                        Text(
                      formatDate(
                        selectedDate,
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      children: [
                        studentField,
                        const SizedBox(
                          height:
                              12,
                        ),
                        subjectField,
                        const SizedBox(
                          height:
                              12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  statusField,
                            ),
                            const SizedBox(
                              width:
                                  10,
                            ),
                            Expanded(
                              child:
                                  date,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height:
                              12,
                        ),
                        Align(
                          alignment:
                              Alignment.centerRight,
                          child:
                              FilledButton.icon(
                            onPressed:
                                saving
                                    ? null
                                    : save,
                            icon:
                                const Icon(
                              Icons
                                  .save_rounded,
                            ),
                            label:
                                const Text(
                              'Save',
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child:
                            studentField,
                      ),
                      const SizedBox(
                        width:
                            10,
                      ),
                      Expanded(
                        child:
                            subjectField,
                      ),
                      const SizedBox(
                        width:
                            10,
                      ),
                      SizedBox(
                        width:
                            145,
                        child:
                            statusField,
                      ),
                      const SizedBox(
                        width:
                            10,
                      ),
                      date,
                      const SizedBox(
                        width:
                            10,
                      ),
                      FilledButton.icon(
                        onPressed:
                            saving
                                ? null
                                : save,
                        icon:
                            const Icon(
                          Icons
                              .save_rounded,
                        ),
                        label:
                            const Text(
                          'Save',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height:
                14,
          ),
          Expanded(
            child:
                Card(
              child:
                  rows.isEmpty
                      ? const EmptyState(
                          icon:
                              Icons
                                  .fact_check_outlined,
                          title:
                              'No attendance',
                          message:
                              'Saved attendance records will appear here.',
                        )
                      : ListView.separated(
                          itemCount:
                              rows.length,
                          separatorBuilder:
                              (_, _) =>
                                  const Divider(
                            height:
                                1,
                          ),
                          itemBuilder:
                              (
                            _,
                            i,
                          ) {
                            final row =
                                rows[i];

                            final present =
                                '${row['status'] ?? ''}'
                                        .toUpperCase() ==
                                    'PRESENT';

                            return ListTile(
                              title:
                                  Text(
                                'Student #${row['student_id']} • Subject #${row['subject_id']}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              subtitle:
                                  Text(
                                '${row['date'] ?? '-'}',
                              ),
                              leading:
                                  CircleAvatar(
                                backgroundColor:
                                    present
                                        ? kSoft
                                        : Colors.red.withValues(
                                            alpha:
                                                .08,
                                          ),
                                child:
                                    Icon(
                                  present
                                      ? Icons
                                          .check_rounded
                                      : Icons
                                          .close_rounded,
                                  color:
                                      present
                                          ? kDark
                                          : Colors.red,
                                ),
                              ),
                              trailing:
                                  StatusChip(
                                text:
                                    '${row['status'] ?? '-'}',
                                good:
                                    present,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FEES
// ============================================================================

class FeesPage
    extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() =>
      _FeesPageState();
}

class _FeesPageState
    extends State<FeesPage> {
  List<dynamic> students = [];
  List<dynamic> fees = [];

  int? selectedStudent;

  bool loading = true;
  bool feeLoading = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final response =
        await api.get(
      '/api/students',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        students =
            jsonDecode(
          response.body,
        ) as List<dynamic>;

        if (students.isNotEmpty &&
            selectedStudent ==
                null) {
          selectedStudent =
              _int(
            students.first['id'],
          );
        }

        loading = false;
      });

      if (selectedStudent !=
          null) {
        loadFees();
      }
    } else {
      setState(() =>
          loading = false);
    }
  }

  Future<void> loadFees() async {
    if (selectedStudent ==
        null) {
      return;
    }

    setState(() =>
        feeLoading = true);

    final response =
        await api.get(
      '/api/fees/student/$selectedStudent',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        fees =
            jsonDecode(
          response.body,
        ) as List<dynamic>;
      });
    }

    setState(() =>
        feeLoading = false);
  }

  Future<void> recordPayment() async {
    if (fees.isEmpty) {
      return;
    }

    final fee =
        Map<String, dynamic>.from(
      fees.first,
    );

    final id =
        _int(
      fee['id'],
    );

    if (id == null) {
      return;
    }

    final amount =
        TextEditingController();

    final reference =
        TextEditingController();

    final result =
        await showDialog<bool>(
      context: context,
      builder:
          (_) =>
              AlertDialog(
        title:
            const Text(
          'Record payment',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        content:
            SizedBox(
          width:
              450,
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    amount,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal:
                      true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Amount',
                ),
              ),
              const SizedBox(
                height:
                    12,
              ),
              TextField(
                controller:
                    reference,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Reference number',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              false,
            ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed:
                () async {
              final response =
                  await api.post(
                '/api/fees/payment',
                body: {
                  'student_fee_id':
                      id,
                  'amount':
                      double.tryParse(
                            amount.text.trim(),
                          ) ??
                          0,
                  'reference_no':
                      reference.text.trim(),
                },
              );

              if (!mounted) {
                return;
              }

              Navigator.pop(
                context,
                response.statusCode <
                    300,
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content:
                      Text(
                    response.statusCode <
                            300
                        ? 'Payment recorded.'
                        : apiError(
                            response,
                          ),
                  ),
                ),
              );
            },
            child:
                const Text(
              'Save',
            ),
          ),
        ],
      ),
    );

    amount.dispose();
    reference.dispose();

    if (result == true) {
      loadFees();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              kPrimary,
        ),
      );
    }

    final due =
        fees.fold(
      0.0,
      (a, b) =>
          a +
          _asNumber(
            b['amount_due'],
          ),
    );

    final paid =
        fees.fold(
      0.0,
      (a, b) =>
          a +
          _asNumber(
            b['amount_paid'],
          ),
    );

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          PageHeader(
            eyebrow:
                'FINANCE',
            title:
                'Fees & Payments',
            subtitle:
                'Track dues, payments, outstanding balances and payment history.',
            action:
                FilledButton.icon(
              onPressed:
                  fees.isEmpty
                      ? null
                      : recordPayment,
              icon:
                  const Icon(
                Icons
                    .payments_outlined,
              ),
              label:
                  const Text(
                'Record payment',
              ),
            ),
          ),
          const SizedBox(
            height:
                16,
          ),
          Card(
            child:
                Padding(
              padding:
                  const EdgeInsets.all(
                15,
              ),
              child:
                  DropdownButtonFormField<int>(
                initialValue:
                    selectedStudent,
                isExpanded:
                    true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Student',
                  prefixIcon:
                      Icon(
                    Icons
                        .person_search_outlined,
                  ),
                ),
                items:
                    students.map(
                  (item) =>
                      DropdownMenuItem<int>(
                    value:
                        _int(
                      item[
                          'id'],
                    ),
                    child:
                        Text(
                      '${item['roll_no'] ?? ''} • ${item['name'] ?? ''}',
                    ),
                  ),
                ).toList(),
                onChanged:
                    (value) {
                  setState(
                    () =>
                        selectedStudent =
                            value,
                  );

                  loadFees();
                },
              ),
            ),
          ),
          const SizedBox(
            height:
                14,
          ),
          Row(
            children: [
              Expanded(
                child:
                    MetricCard(
                  metric:
                      Metric(
                    'Due',
                    currency(
                      due,
                    ),
                    Icons
                        .receipt_long_rounded,
                  ),
                ),
              ),
              const SizedBox(
                width:
                    12,
              ),
              Expanded(
                child:
                    MetricCard(
                  metric:
                      Metric(
                    'Paid',
                    currency(
                      paid,
                    ),
                    Icons
                        .check_circle_outline_rounded,
                  ),
                ),
              ),
              const SizedBox(
                width:
                    12,
              ),
              Expanded(
                child:
                    MetricCard(
                  metric:
                      Metric(
                    'Outstanding',
                    currency(
                      (due -
                              paid)
                          .clamp(
                        0,
                        double
                            .infinity,
                      ),
                    ),
                    Icons
                        .account_balance_wallet_rounded,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height:
                14,
          ),
          Expanded(
            child:
                feeLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              kPrimary,
                        ),
                      )
                    : fees.isEmpty
                        ? const EmptyState(
                            icon:
                                Icons
                                    .payments_outlined,
                            title:
                                'No fee records',
                            message:
                                'No fees are assigned to this student.',
                          )
                        : Card(
                            child:
                                ListView.separated(
                              itemCount:
                                  fees.length,
                              separatorBuilder:
                                  (_, _) =>
                                      const Divider(
                                height:
                                    1,
                              ),
                              itemBuilder:
                                  (_, i) {
                                final row =
                                    fees[i];

                                return ListTile(
                                  title:
                                      Text(
                                    'Fee #${row['id'] ?? '-'}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                  subtitle:
                                      Text(
                                    'Due ${currency(row['amount_due'])} • Paid ${currency(row['amount_paid'])} • Balance ${currency(row['balance'])}',
                                  ),
                                  trailing:
                                      StatusChip(
                                    text:
                                        '${row['status'] ?? '-'}',
                                    good:
                                        '${row['status'] ?? ''}'.toUpperCase() ==
                                            'PAID',
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMS & MARKS
// ============================================================================

class MarksPage
    extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() =>
      _MarksPageState();
}

class _MarksPageState
    extends State<MarksPage> {
  List<dynamic> subjects = [];
  List<dynamic> assessments = [];
  List<dynamic> students = [];

  int? subjectId;
  int? assessmentId;
  int? studentId;

  final marks =
      TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final responses =
          await Future.wait([
        api.get('/api/subjects'),
        api.get('/api/assessments'),
        api.get('/api/students'),
      ]);

      if (!mounted) return;

      setState(() {
        subjects =
            responses[0].statusCode ==
                    200
                ? jsonDecode(
                    responses[0].body,
                  ) as List<dynamic>
                : [];

        assessments =
            responses[1].statusCode ==
                    200
                ? jsonDecode(
                    responses[1].body,
                  ) as List<dynamic>
                : [];

        students =
            responses[2].statusCode ==
                    200
                ? jsonDecode(
                    responses[2].body,
                  ) as List<dynamic>
                : [];

        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() =>
          loading = false);
    }
  }

  List<dynamic> get filteredAssessments =>
      assessments.where(
        (item) {
          return subjectId == null ||
              _int(
                    item['subject_id'],
                  ) ==
                  subjectId;
        },
      ).toList();

  Future<void> save() async {
    if (subjectId == null ||
        assessmentId == null ||
        studentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Select subject, assessment and student.',
          ),
        ),
      );

      return;
    }

    final value =
        double.tryParse(
      marks.text.trim(),
    );

    if (value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            'Enter valid marks.',
          ),
        ),
      );

      return;
    }

    setState(() =>
        saving = true);

    final response =
        await api.post(
      '/api/marks/bulk',
      body: [
        {
          'student_id':
              studentId,
          'subject_id':
              subjectId,
          'assessment_id':
              assessmentId,
          'marks':
              value,
        },
      ],
    );

    if (!mounted) return;

    setState(() =>
        saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(
          response.statusCode <
                  300
              ? 'Marks saved.'
              : apiError(
                  response,
                ),
        ),
      ),
    );
  }

  Future<void> calculate() async {
    if (subjectId == null) {
      return;
    }

    final response =
        await api.post(
      '/api/results/calculate?subject_id=$subjectId',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(
          response.statusCode <
                  300
              ? 'Results calculated.'
              : apiError(
                  response,
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    marks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              kPrimary,
        ),
      );
    }

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        30,
      ),
      children: [
        const PageHeader(
          eyebrow:
              'ACADEMICS',
          title:
              'Exams & Marks',
          subtitle:
              'Assessment setup, mark entry, validation and backend evaluation.',
        ),
        const SizedBox(
          height:
              18,
        ),
        Card(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              18,
            ),
            child:
                Column(
              children: [
                LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    final compact =
                        constraints
                                .maxWidth <
                            850;

                    final subjectField =
                        DropdownButtonFormField<int>(
                      initialValue:
                          subjectId,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Subject',
                      ),
                      items:
                          subjects.map(
                        (item) =>
                            DropdownMenuItem<int>(
                          value:
                              _int(
                            item[
                                'id'],
                          ),
                          child:
                              Text(
                            '${item['code'] ?? ''} • ${item['name'] ?? ''}',
                          ),
                        ),
                      ).toList(),
                      onChanged:
                          (value) =>
                              setState(
                        () {
                          subjectId =
                              value;
                          assessmentId =
                              null;
                        },
                      ),
                    );

                    final assessmentField =
                        DropdownButtonFormField<int>(
                      initialValue:
                          assessmentId,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Assessment',
                      ),
                      items:
                          filteredAssessments.map(
                        (item) =>
                            DropdownMenuItem<int>(
                          value:
                              _int(
                            item[
                                'id'],
                          ),
                          child:
                              Text(
                            '${item['name'] ?? ''} • Max ${item['max_marks'] ?? '-'}',
                          ),
                        ),
                      ).toList(),
                      onChanged:
                          (value) =>
                              setState(
                        () =>
                            assessmentId =
                                value,
                      ),
                    );

                    final studentField =
                        DropdownButtonFormField<int>(
                      initialValue:
                          studentId,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Student',
                      ),
                      items:
                          students.map(
                        (item) =>
                            DropdownMenuItem<int>(
                          value:
                              _int(
                            item[
                                'id'],
                          ),
                          child:
                              Text(
                            '${item['roll_no'] ?? ''} • ${item['name'] ?? ''}',
                          ),
                        ),
                      ).toList(),
                      onChanged:
                          (value) =>
                              setState(
                        () =>
                            studentId =
                                value,
                      ),
                    );

                    final marksField =
                        TextField(
                      controller:
                          marks,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal:
                            true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Marks',
                      ),
                    );

                    if (compact) {
                      return Column(
                        children: [
                          subjectField,
                          const SizedBox(
                            height:
                                12,
                          ),
                          assessmentField,
                          const SizedBox(
                            height:
                                12,
                          ),
                          studentField,
                          const SizedBox(
                            height:
                                12,
                          ),
                          marksField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child:
                              subjectField,
                        ),
                        const SizedBox(
                          width:
                              10,
                        ),
                        Expanded(
                          child:
                              assessmentField,
                        ),
                        const SizedBox(
                          width:
                              10,
                        ),
                        Expanded(
                          child:
                              studentField,
                        ),
                        const SizedBox(
                          width:
                              10,
                        ),
                        SizedBox(
                          width:
                              125,
                          child:
                              marksField,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height:
                      15,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          calculate,
                      icon:
                          const Icon(
                        Icons
                            .auto_awesome_rounded,
                      ),
                      label:
                          const Text(
                        'Calculate results',
                      ),
                    ),
                    const SizedBox(
                      width:
                          10,
                    ),
                    FilledButton.icon(
                      onPressed:
                          saving
                              ? null
                              : save,
                      icon:
                          saving
                              ? const SizedBox(
                                  width:
                                      17,
                                  height:
                                      17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .save_rounded,
                                ),
                      label:
                          const Text(
                        'Save marks',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height:
              18,
        ),
        ...filteredAssessments.map(
          (item) {
            return Card(
              margin:
                  const EdgeInsets.only(
                bottom:
                    9,
              ),
              child:
                  ListTile(
                leading:
                    const CircleAvatar(
                  backgroundColor:
                      kSoft,
                  child:
                      Icon(
                    Icons
                        .assignment_rounded,
                    color:
                        kDark,
                  ),
                ),
                title:
                    Text(
                  '${item['name'] ?? '-'}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                subtitle:
                    Text(
                  'Maximum ${item['max_marks'] ?? '-'} • Weight ${item['weightage'] ?? '-'}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// RESULTS
// ============================================================================

class ResultsPage
    extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() =>
      _ResultsPageState();
}

class _ResultsPageState
    extends State<ResultsPage> {
  List<dynamic> subjects = [];
  List<dynamic> results = [];

  int? subjectId;

  bool loading = true;
  bool resultLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final response =
        await api.get(
      '/api/subjects',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        subjects =
            jsonDecode(
          response.body,
        ) as List<dynamic>;

        loading = false;
      });
    } else {
      setState(() {
        error =
            apiError(response);
        loading = false;
      });
    }
  }

  Future<void> loadResults() async {
    if (subjectId == null) {
      return;
    }

    setState(() =>
        resultLoading = true);

    final response =
        await api.get(
      '/api/results/class?subject_id=$subjectId',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        results =
            jsonDecode(
          response.body,
        ) as List<dynamic>;
      });
    } else {
      setState(() {
        results = [];
        error =
            apiError(response);
      });
    }

    setState(() =>
        resultLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              kPrimary,
        ),
      );
    }

    final eligible =
        results.where(
      (e) =>
          '${e['status'] ?? ''}'
              .toUpperCase() ==
          'ELIGIBLE',
    ).toList();

    final sCount =
        results.where(
      (e) =>
          '${e['grade'] ?? ''}'
              .toUpperCase() ==
          'S',
    ).length;

    final failed =
        results.where(
      (e) =>
          '${e['grade'] ?? ''}'
              .toUpperCase() ==
          'F',
    ).length;

    final average =
        results.isEmpty
            ? 0.0
            : results.fold(
                    0.0,
                    (
                      a,
                      b,
                    ) =>
                        a +
                        _asNumber(
                          b['score'],
                        ),
                  ) /
                results.length;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        25,
      ),
      child:
          Column(
        children: [
          const PageHeader(
            eyebrow:
                'ACADEMIC EVALUATION',
            title:
                'Class Results',
            subtitle:
                'Ranked results, top-S performance and mandatory F rules.',
          ),
          const SizedBox(
            height:
                18,
          ),
          Card(
            child:
                Padding(
              padding:
                  const EdgeInsets.all(
                15,
              ),
              child:
                  DropdownButtonFormField<int>(
                initialValue:
                    subjectId,
                isExpanded:
                    true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Subject',
                  prefixIcon:
                      Icon(
                    Icons
                        .menu_book_outlined,
                  ),
                ),
                items:
                    subjects.map(
                  (item) =>
                      DropdownMenuItem<int>(
                    value:
                        _int(
                      item[
                          'id'],
                    ),
                    child:
                        Text(
                      '${item['code'] ?? ''} • ${item['name'] ?? ''}',
                    ),
                  ),
                ).toList(),
                onChanged:
                    (value) {
                  setState(
                    () =>
                        subjectId =
                            value,
                  );

                  loadResults();
                },
              ),
            ),
          ),
          const SizedBox(
            height:
                14,
          ),
          if (results.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child:
                      MetricCard(
                    metric:
                        Metric(
                      'Eligible',
                      '${
                              eligible.length
                            }',
                      Icons
                          .verified_rounded,
                    ),
                  ),
                ),
                const SizedBox(
                  width:
                      12,
                ),
                Expanded(
                  child:
                      MetricCard(
                    metric:
                        Metric(
                      'Top S',
                      '$sCount',
                      Icons
                          .stars_rounded,
                    ),
                  ),
                ),
                const SizedBox(
                  width:
                      12,
                ),
                Expanded(
                  child:
                      MetricCard(
                    metric:
                        Metric(
                      'Failures',
                      '$failed',
                      Icons
                          .warning_amber_rounded,
                    ),
                  ),
                ),
                const SizedBox(
                  width:
                      12,
                ),
                Expanded(
                  child:
                      MetricCard(
                    metric:
                        Metric(
                      'Class avg',
                      average.toStringAsFixed(
                        1,
                      ),
                      Icons
                          .trending_up_rounded,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(
            height:
                14,
          ),
          Expanded(
            child:
                resultLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              kPrimary,
                        ),
                      )
                    : error != null
                        ? CenterMessage(
                            icon:
                                Icons
                                    .bar_chart_outlined,
                            title:
                                'Results unavailable',
                            message:
                                error!,
                            actionText:
                                'Retry',
                            onAction:
                                loadResults,
                          )
                        : results.isEmpty
                            ? const EmptyState(
                                icon:
                                    Icons
                                        .bar_chart_outlined,
                                title:
                                    'No class results',
                                message:
                                    'Calculate results for a subject first.',
                              )
                            : Card(
                                child:
                                    ListView.separated(
                                  itemCount:
                                      results.length,
                                  separatorBuilder:
                                      (_, _) =>
                                          const Divider(
                                    height:
                                        1,
                                  ),
                                  itemBuilder:
                                      (_, i) {
                                    final row =
                                        results[
                                            i];

                                    final grade =
                                        '${row['grade'] ?? '-'}';

                                    final isF =
                                        grade.toUpperCase() ==
                                            'F';

                                    return ListTile(
                                      leading:
                                          CircleAvatar(
                                        backgroundColor:
                                            isF
                                                ? Colors.red.withValues(
                                                    alpha:
                                                        .08,
                                                  )
                                                : kSoft,
                                        foregroundColor:
                                            isF
                                                ? Colors.red
                                                : kDark,
                                        child:
                                            Text(
                                          '${row['rank'] ?? i + 1}',
                                        ),
                                      ),
                                      title:
                                          Text(
                                        '${row['roll_no'] ?? '-'} • ${row['name'] ?? '-'}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                      subtitle:
                                          Text(
                                        'Score ${row['score'] ?? '-'} • Grade $grade • GP ${row['grade_point'] ?? '-'}',
                                      ),
                                      trailing:
                                          StatusChip(
                                        text:
                                            grade,
                                        good:
                                            !isF,
                                      ),
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GRADING POLICY
// ============================================================================

class PolicyPage
    extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() =>
      _PolicyPageState();
}

class _PolicyPageState
    extends State<PolicyPage> {
  Map<String, dynamic>? data;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response =
        await api.get(
      '/api/policies/grading',
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        data =
            Map<String, dynamic>.from(
          jsonDecode(
            response.body,
          ),
        );
      });
    } else {
      setState(() {
        error =
            apiError(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return CenterMessage(
        icon:
            Icons.rule_outlined,
        title:
            'Policy unavailable',
        message:
            error!,
        actionText:
            'Retry',
        onAction:
            load,
      );
    }

    if (data == null) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              kPrimary,
        ),
      );
    }

    final policy =
        data!['policy']
            as Map<String, dynamic>?;

    final bands =
        (data!['bands']
                as List<dynamic>?) ??
            [];

    if (policy == null) {
      return const EmptyState(
        icon:
            Icons.rule_outlined,
        title:
            'No grading policy',
        message:
            'Configure a grading policy from the backend first.',
      );
    }

    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        30,
      ),
      children: [
        const PageHeader(
          eyebrow:
              'ACADEMIC ENGINE',
          title:
              'Grading Policy',
          subtitle:
              'Policy-driven rules keep grading configurable and traceable.',
        ),
        const SizedBox(
          height:
              18,
        ),
        Card(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons
                          .verified_user_rounded,
                      color:
                          kPrimary,
                    ),
                    const SizedBox(
                      width:
                          10,
                    ),
                    Expanded(
                      child:
                          Text(
                        '${policy['name'] ?? 'Grading Policy'}',
                        style:
                            const TextStyle(
                          fontSize:
                              19,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                    StatusChip(
                      text:
                          'v${policy['version'] ?? '-'}',
                      good:
                          true,
                    ),
                  ],
                ),
                const SizedBox(
                  height:
                      18,
                ),
                Wrap(
                  spacing:
                      12,
                  runSpacing:
                      12,
                  children: [
                    RuleTile(
                      label:
                          'TEE minimum',
                      value:
                          '${policy['pass_tee_min'] ?? '-'}',
                    ),
                    RuleTile(
                      label:
                          'Qualifying minimum',
                      value:
                          '${policy['pass_total_min'] ?? '-'}',
                    ),
                    RuleTile(
                      label:
                          'Top S count',
                      value:
                          '${policy['top_s_count'] ?? '-'}',
                    ),
                    RuleTile(
                      label:
                          'Qualifying scale',
                      value:
                          '${policy['qualifying_scale'] ?? '-'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height:
              14,
        ),
        const Text(
          'Grade bands',
          style:
              TextStyle(
            fontSize:
                17,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        const SizedBox(
          height:
              8,
        ),
        ...bands.map(
          (item) {
            return Card(
              margin:
                  const EdgeInsets.only(
                bottom:
                    8,
              ),
              child:
                  ListTile(
                leading:
                    CircleAvatar(
                  backgroundColor:
                      kSoft,
                  foregroundColor:
                      kDark,
                  child:
                      Text(
                    '${item['grade'] ?? '-'}',
                  ),
                ),
                title:
                    Text(
                  '${item['grade'] ?? '-'} • ${item['grade_point'] ?? '-'} points',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                subtitle:
                    Text(
                  '${item['min_score'] ?? '-'} to ${item['max_score'] ?? '-'}',
                ),
              ),
            );
          },
        ),
        const SizedBox(
          height:
              8,
        ),
        const AlertPanel(
          title:
              'Backend authoritative',
          message:
              'Grades, GPA and CGPA are calculated by the backend. The frontend only displays the finalized policy results.',
          icon:
              Icons
                  .security_rounded,
        ),
      ],
    );
  }
}

class RuleTile
    extends StatelessWidget {
  final String label;
  final String value;

  const RuleTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          200,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            kBackground,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              color:
                  kMuted,
              fontSize:
                  11,
            ),
          ),
          const SizedBox(
            height:
                4,
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize:
                  19,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCOUNTS
// ============================================================================

class AccountPage
    extends StatefulWidget {
  final bool adminMode;

  const AccountPage({
    super.key,
    required this.adminMode,
  });

  @override
  State<AccountPage> createState() =>
      _AccountPageState();
}

class _AccountPageState
    extends State<AccountPage> {
  final formKey =
      GlobalKey<FormState>();

  final name =
      TextEditingController();

  final email =
      TextEditingController();

  final password =
      TextEditingController();

  final confirm =
      TextEditingController();

  final roll =
      TextEditingController();

  final semester =
      TextEditingController(
    text:
        '1',
  );

  final phone =
      TextEditingController();

  List<dynamic> departments = [];
  List<dynamic> sections = [];

  String role =
      'STUDENT';

  int? departmentId;
  int? sectionId;

  bool loading =
      true;

  bool saving =
      false;

  String? error;

  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  Future<void> loadOptions() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Before login, the normal master-data endpoints may be protected.
      // Prefer a dedicated public registration-options endpoint when available.
      http.Response departmentsResponse;
      http.Response sectionsResponse;

      if (!widget.adminMode) {
        final publicResponse = await api.get(
          '/api/auth/registration-options',
        );

        if (publicResponse.statusCode == 200) {
          final decoded = jsonDecode(publicResponse.body);
          final loadedDepartments =
              (decoded['departments'] as List<dynamic>?) ?? <dynamic>[];
          final loadedSections =
              (decoded['sections'] as List<dynamic>?) ?? <dynamic>[];

          if (!mounted) return;
          setState(() {
            departments = loadedDepartments;
            sections = loadedSections;
            loading = false;
            error = null;
          });
          return;
        }

        // Fall back to the protected endpoints. This works for the admin
        // account-management screen and also supports backends that expose
        // master data publicly.
        departmentsResponse = await api.get('/api/departments');
        sectionsResponse = await api.get('/api/sections');
      } else {
        final responses = await Future.wait([
          api.get('/api/departments'),
          api.get('/api/sections'),
        ]);
        departmentsResponse = responses[0];
        sectionsResponse = responses[1];
      }

      if (!mounted) return;

      if (departmentsResponse.statusCode == 200 &&
          sectionsResponse.statusCode == 200) {
        final departmentData = jsonDecode(departmentsResponse.body);
        final sectionData = jsonDecode(sectionsResponse.body);

        if (departmentData is! List || sectionData is! List) {
          setState(() {
            loading = false;
            error = 'Invalid department/section data from FastAPI.';
          });
          return;
        }

        setState(() {
          departments = List<dynamic>.from(departmentData);
          sections = List<dynamic>.from(sectionData);
          loading = false;
          error = null;
        });
      } else {
        final failed = departmentsResponse.statusCode != 200
            ? departmentsResponse
            : sectionsResponse;

        setState(() {
          loading = false;
          error = failed.statusCode == 401 || failed.statusCode == 403
              ? 'Department and section choices require a public registration-options endpoint in FastAPI.'
              : apiError(failed);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load departments and sections: $e';
      });
    }
  }

  List<dynamic> get availableSections {
    if (departmentId == null) {
      return List<dynamic>.from(sections);
    }

    return sections.where((item) {
      final itemDepartment = _int(item['department_id']);

      return itemDepartment == null || itemDepartment == departmentId;
    }).toList();
  }

  Future<void> submit() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    if (password.text !=
        confirm.text) {
      setState(() {
        error =
            'Passwords do not match.';
      });

      return;
    }

    if (role == 'STUDENT') {
      if (departmentId == null ||
          sectionId == null) {
        setState(() {
          error =
              'Select department and section.';
        });

        return;
      }
    }

    if (role == 'FACULTY' &&
        departmentId == null) {
      setState(() {
        error =
            'Select a department.';
      });

      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    final body =
        <String, dynamic>{
      'name':
          name.text.trim(),
      'email':
          email.text.trim(),
      'password':
          password.text,
      'role':
          role,
    };

    if (role == 'STUDENT') {
      body.addAll({
        'roll_no':
            roll.text.trim(),
        'department_id':
            departmentId,
        'semester':
            int.tryParse(
                  semester.text.trim(),
                ) ??
                1,
        'section':
            sectionId,
        'phone':
            phone.text.trim().isEmpty
                ? null
                : phone.text.trim(),
      });
    }

    if (role == 'FACULTY') {
      body['department_id'] =
          departmentId;
    }

    final endpoint =
        widget.adminMode
            ? '/api/auth/admin/create-user'
            : '/api/auth/register';

    try {
      final response =
          await api.post(
        endpoint,
        body:
            body,
      );

      if (!mounted) return;

      if (response.statusCode >=
              200 &&
          response.statusCode <
              300) {
        if (widget.adminMode) {
          clearForm();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content:
                  Text(
                '${roleLabel(role)} account created.',
              ),
            ),
          );
        } else {
          await showDialog<void>(
            context:
                context,
            builder:
                (_) =>
                    AlertDialog(
              title:
                  const Text(
                'Account created',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              content:
                  const Text(
                'Your account and ERP profile were created successfully.',
              ),
              actions: [
                FilledButton(
                  onPressed:
                      () =>
                          Navigator.pop(
                    context,
                  ),
                  child:
                      const Text(
                    'Continue',
                  ),
                ),
              ],
            ),
          );

          if (!mounted) {
            return;
          }

          Navigator.pop(context, {'email': email.text.trim(), 'password': password.text});
        }
      } else {
        setState(() {
          error =
              apiError(response);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error =
            'Could not connect to FastAPI.';
      });
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void clearForm() {
    name.clear();
    email.clear();
    password.clear();
    confirm.clear();
    roll.clear();
    phone.clear();
    semester.text =
        '1';

    setState(() {
      departmentId =
          null;
      sectionId =
          null;
    });
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    roll.dispose();
    semester.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicMode =
        !widget.adminMode;

    return Scaffold(
      appBar:
          AppBar(
        title:
            Text(
          publicMode
              ? 'Create account'
              : 'Account management',
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body:
          Form(
        key:
            formKey,
        child:
            ListView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            35,
          ),
          children: [
            PageHeader(
              eyebrow:
                  publicMode
                      ? 'REGISTRATION'
                      : 'ADMINISTRATION',
              title:
                  publicMode
                      ? 'Create your ERP account'
                      : 'Create an ERP account',
              subtitle:
                  publicMode
                      ? 'Create a Student or Faculty account.'
                      : 'Provision Student, Faculty or Administrator accounts.',
            ),
            const SizedBox(
              height:
                  18,
            ),
            Card(
              child:
                  Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child:
                    Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                          role,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Account type',
                        prefixIcon:
                            Icon(
                          Icons
                              .badge_outlined,
                        ),
                      ),
                      items: [
                        if (widget
                            .adminMode)
                          const DropdownMenuItem(
                            value:
                                'ADMIN',
                            child:
                                Text(
                              'Administrator',
                            ),
                          ),
                        const DropdownMenuItem(
                          value:
                              'FACULTY',
                          child:
                              Text(
                            'Faculty',
                          ),
                        ),
                        const DropdownMenuItem(
                          value:
                              'STUDENT',
                          child:
                              Text(
                            'Student',
                          ),
                        ),
                      ],
                      onChanged:
                          saving
                              ? null
                              : (value) {
                                  if (value ==
                                      null) {
                                    return;
                                  }

                                  setState(
                                    () {
                                      role =
                                          value;
                                      departmentId =
                                          null;
                                      sectionId =
                                          null;
                                    },
                                  );
                                },
                    ),
                    if (role !=
                        'ADMIN') ...[
                      const SizedBox(
                        height:
                            14,
                      ),
                      TextFormField(
                        controller:
                            name,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Full name',
                          prefixIcon:
                              Icon(
                            Icons
                                .person_outline,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Name is required.';
                          }

                          return null;
                        },
                      ),
                    ],
                    const SizedBox(
                      height:
                          14,
                    ),
                    TextFormField(
                      controller:
                          email,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Email',
                        prefixIcon:
                            Icon(
                          Icons
                              .email_outlined,
                        ),
                      ),
                      validator:
                          (value) {
                        if (value ==
                                null ||
                            !value
                                .contains(
                              '@',
                            )) {
                          return 'Enter a valid email.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height:
                          14,
                    ),
                    TextFormField(
                      controller:
                          password,
                      obscureText:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Password',
                        prefixIcon:
                            Icon(
                          Icons
                              .lock_outline,
                        ),
                      ),
                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value.length <
                                6) {
                          return 'Minimum 6 characters.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height:
                          14,
                    ),
                    TextFormField(
                      controller:
                          confirm,
                      obscureText:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Confirm password',
                        prefixIcon:
                            Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                      ),
                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value !=
                                password
                                    .text) {
                          return 'Passwords do not match.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (role ==
                'STUDENT') ...[
              const SizedBox(
                height:
                    14,
              ),
              Card(
                child:
                    Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child:
                      Column(
                    children: [
                      TextFormField(
                        controller:
                            roll,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Roll number',
                          prefixIcon:
                              Icon(
                            Icons
                                .numbers_outlined,
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Roll number is required.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height:
                            14,
                      ),
                      if (loading)
                        const LinearProgressIndicator()
                      else
                        LayoutBuilder(
                          builder:
                              (
                            context,
                            constraints,
                          ) {
                            if (constraints
                                    .maxWidth <
                                700) {
                              return Column(
                                children: [
                                  departmentDropdown(),
                                  const SizedBox(
                                    height:
                                        14,
                                  ),
                                  sectionDropdown(),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      departmentDropdown(),
                                ),
                                const SizedBox(
                                  width:
                                      12,
                                ),
                                Expanded(
                                  child:
                                      sectionDropdown(),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(
                        height:
                            14,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  semester,
                              keyboardType:
                                  TextInputType
                                      .number,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Semester',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width:
                                12,
                          ),
                          Expanded(
                            child:
                                TextFormField(
                              controller:
                                  phone,
                              keyboardType:
                                  TextInputType
                                      .phone,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (role ==
                'FACULTY') ...[
              const SizedBox(
                height:
                    14,
              ),
              Card(
                child:
                    Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child:
                      loading
                          ? const LinearProgressIndicator()
                          : departmentDropdown(),
                ),
              ),
            ],
            if (error !=
                null) ...[
              const SizedBox(
                height:
                    14,
              ),
              ErrorBanner(
                message:
                    error!,
              ),
            ],
            const SizedBox(
              height:
                  18,
            ),
            SizedBox(
              height:
                  52,
              child:
                  FilledButton.icon(
                onPressed:
                    loading ||
                            saving
                        ? null
                        : submit,
                icon:
                    saving
                        ? const SizedBox(
                            width:
                                18,
                            height:
                                18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .person_add_alt_1_rounded,
                          ),
                label:
                    Text(
                  saving
                      ? 'Creating account...'
                      : 'Create account',
                ),
              ),
            ),
            if (publicMode)
              Center(
                child:
                    TextButton(
                  onPressed:
                      saving
                          ? null
                          : () =>
                              Navigator.pop(
                            context,
                          ),
                  child:
                      const Text(
                    'Back to login',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget departmentDropdown() {
    return DropdownButtonFormField<int>(
      initialValue:
          departmentId,
      isExpanded:
          true,
      decoration:
          const InputDecoration(
        labelText:
            'Department',
        prefixIcon:
            Icon(
          Icons
              .apartment_outlined,
        ),
      ),
      items:
          departments.map(
        (item) =>
            DropdownMenuItem<int>(
          value:
              _int(
            item[
                'id'],
          ),
          child:
              Text(
            '${item['code'] ?? ''} ${item['name'] ?? ''}',
            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ).toList(),
      onChanged:
          saving || loading
              ? null
              : (value) {
                  setState(
                    () {
                      departmentId =
                          value;
                      sectionId =
                          null;
                    },
                  );
                },
      validator:
          role == 'ADMIN'
              ? null
              : (_) {
                  if (departmentId ==
                      null) {
                    return 'Select a department.';
                  }

                  return null;
                },
    );
  }

  Widget sectionDropdown() {
    final list = availableSections;

    final safeValue = list.any(
      (item) => _int(item['id']) == sectionId,
    )
        ? sectionId
        : null;

    return DropdownButtonFormField<int>(
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Section',
        helperText: loading
            ? 'Loading sections...'
            : list.isEmpty
                ? departmentId == null
                    ? 'Select a department first'
                    : 'No sections for this department'
                : '${list.length} section${list.length == 1 ? '' : 's'} available',
        prefixIcon: const Icon(Icons.groups_outlined),
      ),
      items: list
          .map(
            (item) => DropdownMenuItem<int>(
              value: _int(item['id']),
              child: Text(
                '${item['name'] ?? 'Section'}'
                '${item['semester'] != null ? ' • Semester ${item['semester']}' : ''}'
                '${item['academic_year'] != null ? ' • ${item['academic_year']}' : ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .where((item) => item.value != null)
          .toList(),
      onChanged: saving || loading || list.isEmpty
          ? null
          : (value) {
              setState(() {
                sectionId = value;
                if (value != null) {
                  final selected = sections.cast<Map<String, dynamic>?>().firstWhere(
                        (item) => _int(item?['id']) == value,
                        orElse: () => null,
                      );
                  final sectionSemester = _int(selected?['semester']);
                  if (sectionSemester != null) {
                    semester.text = '$sectionSemester';
                  }
                }
              });
            },
      validator: role == 'STUDENT'
          ? (_) {
              if (sectionId == null) {
                return list.isEmpty
                    ? 'No section is available for the selected department.'
                    : 'Select a section.';
              }
              return null;
            }
          : null,
    );
  }
}

// ============================================================================
// REPORTS
// ============================================================================

class ReportsPage
    extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() =>
      _ReportsPageState();
}

class _ReportsPageState
    extends State<ReportsPage> {
  List<dynamic> students = [];
  List<dynamic> subjects = [];

  int? studentId;
  int? subjectId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final responses =
        await Future.wait([
      api.get('/api/students'),
      api.get('/api/subjects'),
    ]);

    if (!mounted) return;

    setState(() {
      students =
          responses[0].statusCode ==
                  200
              ? jsonDecode(
                  responses[0].body,
                ) as List<dynamic>
              : [];

      subjects =
          responses[1].statusCode ==
                  200
              ? jsonDecode(
                  responses[1].body,
                ) as List<dynamic>
              : [];
    });
  }

  void showEndpoint(String endpoint) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          AlertDialog(
        title:
            const Text(
          'Report endpoint',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
        content:
            SelectableText(
          '$apiBaseUrl$endpoint',
        ),
        actions: [
          FilledButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
            ),
            child:
                const Text(
              'Close',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        14,
        22,
        30,
      ),
      children: [
        const PageHeader(
          eyebrow:
              'REPORTING',
          title:
              'Reports',
          subtitle:
              'Student transcripts and class result exports from the backend.',
        ),
        const SizedBox(
          height:
              18,
        ),
        Card(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student transcript / report',
                  style:
                      TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height:
                      13,
                ),
                DropdownButtonFormField<int>(
                  initialValue:
                      studentId,
                  isExpanded:
                      true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Student',
                  ),
                  items:
                      students.map(
                    (item) =>
                        DropdownMenuItem<int>(
                      value:
                          _int(
                        item[
                            'id'],
                      ),
                      child:
                          Text(
                        '${item['roll_no'] ?? ''} • ${item['name'] ?? ''}',
                      ),
                    ),
                  ).toList(),
                  onChanged:
                      (value) =>
                          setState(
                    () =>
                        studentId =
                            value,
                  ),
                ),
                const SizedBox(
                  height:
                      12,
                ),
                FilledButton.icon(
                  onPressed:
                      studentId ==
                              null
                          ? null
                          : () =>
                              showEndpoint(
                            '/api/reports/student/$studentId/pdf',
                          ),
                  icon:
                      const Icon(
                    Icons
                        .picture_as_pdf_rounded,
                  ),
                  label:
                      const Text(
                    'Student PDF',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height:
              14,
        ),
        Card(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Class result report',
                  style:
                      TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height:
                      13,
                ),
                DropdownButtonFormField<int>(
                  initialValue:
                      subjectId,
                  isExpanded:
                      true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Subject',
                  ),
                  items:
                      subjects.map(
                    (item) =>
                        DropdownMenuItem<int>(
                      value:
                          _int(
                        item[
                            'id'],
                      ),
                      child:
                          Text(
                        '${item['code'] ?? ''} • ${item['name'] ?? ''}',
                      ),
                    ),
                  ).toList(),
                  onChanged:
                      (value) =>
                          setState(
                    () =>
                        subjectId =
                            value,
                  ),
                ),
                const SizedBox(
                  height:
                      12,
                ),
                FilledButton.icon(
                  onPressed:
                      subjectId ==
                              null
                          ? null
                          : () =>
                              showEndpoint(
                            '/api/reports/class/excel?subject_id=$subjectId',
                          ),
                  icon:
                      const Icon(
                    Icons
                        .table_chart_rounded,
                  ),
                  label:
                      const Text(
                    'Class Excel',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height:
              14,
        ),
        const AlertPanel(
          title:
              'Server-side reports',
          message:
              'The backend generates the actual PDF/XLSX content. This screen keeps the frontend responsible only for selecting the report target.',
          icon:
              Icons
                  .cloud_done_rounded,
        ),
      ],
    );
  }
}

// ============================================================================
// COMMON UI
// ============================================================================

class BrandMark
    extends StatelessWidget {
  final double size;
  final bool dark;

  const BrandMark({
    super.key,
    required this.size,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          size,
      height:
          size,
      decoration:
          BoxDecoration(
        color:
            dark
                ? kPrimary
                : Colors.white,
        borderRadius:
            BorderRadius.circular(
          size *
              .28,
        ),
      ),
      child:
          Icon(
        Icons
            .school_rounded,
        color:
            dark
                ? Colors.white
                : kPrimary,
        size:
            size *
                .52,
      ),
    );
  }
}

class PageHeader
    extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style:
                    const TextStyle(
                  color:
                      kPrimary,
                  fontSize:
                      11,
                  letterSpacing:
                      1.4,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height:
                    4,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      kDark,
                  fontSize:
                      28,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height:
                    5,
              ),
              Text(
                subtitle,
                style:
                    const TextStyle(
                  color:
                      kMuted,
                  fontSize:
                      13,
                  height:
                      1.45,
                ),
              ),
            ],
          ),
        ),
        if (action !=
            null)
          Padding(
            padding:
                const EdgeInsets.only(
              left:
                  10,
            ),
            child:
                action!,
          ),
      ],
    );
  }
}

class StatusChip
    extends StatelessWidget {
  final String text;
  final bool good;

  const StatusChip({
    super.key,
    required this.text,
    required this.good,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        good
            ? kPrimary
            : Colors.orange;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            10,
        vertical:
            6,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha:
              .10,
        ),
        borderRadius:
            BorderRadius.circular(
          9,
        ),
      ),
      child:
          Text(
        text,
        style:
            TextStyle(
          color:
              color,
          fontSize:
              11,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }
}

class ErrorBanner
    extends StatelessWidget {
  final String message;

  const ErrorBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.red.withValues(
          alpha:
              .06,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              Colors.red.withValues(
            alpha:
                .18,
          ),
        ),
      ),
      child:
          Row(
        children: [
          const Icon(
            Icons.error_outline,
            color:
                Colors.red,
          ),
          const SizedBox(
            width:
                10,
          ),
          Expanded(
            child:
                Text(
              message,
              style:
                  const TextStyle(
                color:
                    Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CenterMessage
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const CenterMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size:
                  55,
              color:
                  kMuted,
            ),
            const SizedBox(
              height:
                  13,
            ),
            Text(
              title,
              style:
                  const TextStyle(
                fontSize:
                    18,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height:
                  6,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    kMuted,
              ),
            ),
            const SizedBox(
              height:
                  15,
            ),
            FilledButton.icon(
              onPressed:
                  onAction,
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  Text(
                actionText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          35,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size:
                  54,
              color:
                  kMuted.withValues(
                alpha:
                    .45,
              ),
            ),
            const SizedBox(
              height:
                  13,
            ),
            Text(
              title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height:
                  6,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoBox
    extends StatelessWidget {
  final String title;
  final List<String> lines;

  const InfoBox({
    super.key,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            kBackground,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height:
                7,
          ),
          ...lines.map(
            (line) =>
                Text(
              line,
              style:
                  const TextStyle(
                color:
                    kMuted,
                fontSize:
                    12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Text(
        label,
        style:
            const TextStyle(
          color:
              kMuted,
          fontSize:
              12,
        ),
      ),
      trailing:
          Text(
        value,
        textAlign:
            TextAlign.right,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

class SnapshotRow
    extends StatelessWidget {
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;

  const SnapshotRow({
    super.key,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              SnapshotTile(
            label:
                firstLabel,
            value:
                firstValue,
            icon:
                Icons
                    .insights_rounded,
          ),
        ),
        const SizedBox(
          width:
              10,
        ),
        Expanded(
          child:
              SnapshotTile(
            label:
                secondLabel,
            value:
                secondValue,
            icon:
                Icons
                    .analytics_rounded,
          ),
        ),
      ],
    );
  }
}

class SnapshotTile
    extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SnapshotTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            kBackground,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                kPrimary,
          ),
          const SizedBox(
            width:
                10,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    color:
                        kMuted,
                    fontSize:
                        11,
                  ),
                ),
                const SizedBox(
                  height:
                      3,
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertPanel
    extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const AlertPanel({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFF7E8),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color:
              Colors.orange.withValues(
            alpha:
                .20,
          ),
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                Colors.orange,
          ),
          const SizedBox(
            width:
                10,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                Text(
                  message,
                  style:
                      const TextStyle(
                    color:
                        kMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ADD STUDENT DIALOG
// ============================================================================

Future<void> showStudentDialog(
  BuildContext context,
) async {
  final roll =
      TextEditingController();

  final name =
      TextEditingController();

  final email =
      TextEditingController();

  final phone =
      TextEditingController();

  final semester =
      TextEditingController(
    text:
        '1',
  );

  List<dynamic> departments = [];
  List<dynamic> sections = [];

  int? departmentId;
  int? sectionId;

  try {
    final responses =
        await Future.wait([
      api.get('/api/departments'),
      api.get('/api/sections'),
    ]);

    departments =
        responses[0].statusCode ==
                200
            ? jsonDecode(
                responses[0].body,
              ) as List<dynamic>
            : [];

    sections =
        responses[1].statusCode ==
                200
            ? jsonDecode(
                responses[1].body,
              ) as List<dynamic>
            : [];
  } catch (_) {}

  if (!context.mounted) {
    roll.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    semester.dispose();
    return;
  }

  await showDialog<void>(
    context:
        context,
    builder:
        (_) =>
            StatefulBuilder(
      builder:
          (
        context,
        setState,
      ) {
        // Filter sections by department only.
        // Semester is automatically synchronized from the selected section,
        // so the user is never trapped by an initial/default semester.
        final filtered = sections.where((item) {
          final dep = _int(item['department_id']);
          return departmentId == null ||
              dep == null ||
              dep == departmentId;
        }).toList();

        return AlertDialog(
          title:
              const Text(
            'Add student',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          content:
              SizedBox(
            width:
                520,
            child:
                SingleChildScrollView(
              child:
                  Column(
                children: [
                  TextField(
                    controller:
                        roll,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Roll number',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextField(
                    controller:
                        name,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Name',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextField(
                    controller:
                        email,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Email',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  DropdownButtonFormField<int>(
                    initialValue:
                        departmentId,
                    isExpanded:
                        true,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Department',
                    ),
                    items:
                        departments.map(
                      (item) =>
                          DropdownMenuItem<int>(
                        value:
                            _int(
                          item[
                              'id'],
                        ),
                        child:
                            Text(
                          '${item['code']} • ${item['name']}',
                        ),
                      ),
                    ).toList(),
                    onChanged:
                        (value) {
                      setState(
                        () {
                          departmentId =
                              value;

                          sectionId =
                              null;
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:
                            TextField(
                          controller:
                              semester,
                          keyboardType:
                              TextInputType.number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Semester',
                          ),
                          onChanged:
                              (_) =>
                                  setState(
                            () {
                              sectionId =
                                  null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width:
                            12,
                      ),
                      Expanded(
                        child:
                            DropdownButtonFormField<int>(
                          initialValue:
                              sectionId,
                          isExpanded:
                              true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Section',
                          ),
                          items:
                              filtered.map(
                            (item) =>
                                DropdownMenuItem<int>(
                              value:
                                  _int(
                                item[
                                    'id'],
                              ),
                              child:
                                  Text(
                                '${item['name']}',
                              ),
                            ),
                          ).toList(),
                          onChanged:
                              (value) =>
                                  setState(
                            () =>
                                sectionId =
                                    value,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextField(
                    controller:
                        phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Phone',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.pop(
                context,
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed:
                  roll.text.trim().isEmpty ||
                          name.text.trim().isEmpty ||
                          email.text.trim().isEmpty ||
                          departmentId ==
                              null ||
                          sectionId ==
                              null
                      ? null
                      : () async {
                          final response =
                              await api.post(
                            '/api/students',
                            body: {
                              'roll_no':
                                  roll.text.trim(),
                              'name':
                                  name.text.trim(),
                              'department_id':
                                  departmentId,
                              'semester':
                                  int.tryParse(
                                        semester.text.trim(),
                                      ) ??
                                      1,
                              'section':
                                  (sections.cast<Map<String, dynamic>>().firstWhere(
                                    (s) => _int(s['id']) == sectionId,
                                    orElse: () => <String, dynamic>{'name': ''},
                                  )['name'] ?? '').toString(),
                              'section_id': sectionId,
                              'phone':
                                  phone.text.trim().isEmpty
                                      ? null
                                      : phone.text.trim(),
                              'email':
                                  email.text.trim(),
                              'status':
                                  'ACTIVE',
                            },
                          );

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content:
                                  Text(
                                response.statusCode <
                                        300
                                    ? 'Student created.'
                                    : apiError(
                                        response,
                                      ),
                              ),
                            ),
                          );
                        },
              child:
                  const Text(
                'Create',
              ),
            ),
          ],
        );
      },
    ),
  );

  roll.dispose();
  name.dispose();
  email.dispose();
  phone.dispose();
  semester.dispose();
}

// ============================================================================
// HELPERS
// ============================================================================

String apiError(
  http.Response response,
) {
  try {
    final decoded =
        jsonDecode(
      response.body,
    );

    if (decoded is Map &&
        decoded['detail'] !=
            null) {
      return decoded['detail']
          .toString();
    }
  } catch (_) {}

  return 'Request failed (${response.statusCode}).';
}

num _asNumber(
  dynamic value,
) {
  if (value is num) {
    return value;
  }

  return num.tryParse(
        '${value ?? ''}',
      ) ??
      0;
}

int? _int(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  return int.tryParse(
    '${value ?? ''}',
  );
}

String currency(
  dynamic value,
) {
  return '₹${_asNumber(value).toStringAsFixed(0)}';
}

String formatDate(
  DateTime date,
) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String roleLabel(
  String role,
) {
  switch (role.toUpperCase()) {
    case 'ADMIN':
      return 'Administrator';

    case 'FACULTY':
      return 'Faculty';

    case 'STUDENT':
      return 'Student';

    default:
      return role;
  }
}