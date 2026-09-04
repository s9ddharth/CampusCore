class RouteNames {
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Root
  // ---------------------------------------------------------------------------

  static const String root = '/';

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';

  static const String login = '/login';

  static const String forgotPassword = '/forgot-password';

  // ---------------------------------------------------------------------------
  // Admin
  // ---------------------------------------------------------------------------

  static const String admin = '/admin';

  static const String adminDashboard = '/admin/dashboard';

  static const String academicAdmin = '/admin/academic';

  // ---------------------------------------------------------------------------
  // Admin - Students
  // ---------------------------------------------------------------------------

  static const String adminStudents = '/admin/students';

  static const String addStudent = '/admin/students/add';

  static const String editStudent = '/admin/students/edit';

  static const String studentDetails = '/admin/students/details';

  // ---------------------------------------------------------------------------
  // Admin - Faculty
  // ---------------------------------------------------------------------------

  static const String adminFaculty = '/admin/faculty';

  static const String addFaculty = '/admin/faculty/add';

  static const String facultyDetails = '/admin/faculty/details';

  // ---------------------------------------------------------------------------
  // Admin - Departments
  // ---------------------------------------------------------------------------

  static const String adminDepartments = '/admin/departments';

  // ---------------------------------------------------------------------------
  // Admin - Sections
  // ---------------------------------------------------------------------------

  static const String adminSections = '/admin/sections';

  // ---------------------------------------------------------------------------
  // Admin - Subjects
  // ---------------------------------------------------------------------------

  static const String adminSubjects = '/admin/subjects';

  static const String subjectAssignment =
      '/admin/subjects/assignment';

  // ---------------------------------------------------------------------------
  // Admin - Attendance
  // ---------------------------------------------------------------------------

  static const String adminAttendance =
      '/admin/attendance';

  static const String attendanceOverview =
      '/admin/attendance/overview';

  // ---------------------------------------------------------------------------
  // Admin - Exams
  // ---------------------------------------------------------------------------

  static const String adminExams =
      '/admin/exams';

  static const String assessmentSetup =
      '/admin/exams/assessment-setup';

  static const String marksOverview =
      '/admin/exams/marks-overview';

  // ---------------------------------------------------------------------------
  // Admin - Fees
  // ---------------------------------------------------------------------------

  static const String adminFees =
      '/admin/fees';

  static const String feeStructure =
      '/admin/fees/structure';

  static const String payment =
      '/admin/fees/payment';

  // ---------------------------------------------------------------------------
  // Admin - Grading
  // ---------------------------------------------------------------------------

  static const String adminGrading =
      '/admin/grading';

  static const String gradingPolicy =
      '/admin/grading/policy';

  static const String gradeBands =
      '/admin/grading/bands';

  // ---------------------------------------------------------------------------
  // Admin - Results
  // ---------------------------------------------------------------------------

  static const String adminResults =
      '/admin/results';

  static const String classResults =
      '/admin/results/class';

  static const String studentResult =
      '/admin/results/student';

  // ---------------------------------------------------------------------------
  // Admin - Reports
  // ---------------------------------------------------------------------------

  static const String adminReports =
      '/admin/reports';

  static const String classReport =
      '/admin/reports/class';

  static const String studentReport =
      '/admin/reports/student';

  // ---------------------------------------------------------------------------
  // Faculty
  // ---------------------------------------------------------------------------

  static const String faculty =
      '/faculty';

  static const String facultyDashboard =
      '/faculty/dashboard';

  // ---------------------------------------------------------------------------
  // Faculty - Subjects
  // ---------------------------------------------------------------------------

  static const String mySubjects =
      '/faculty/subjects';

  // ---------------------------------------------------------------------------
  // Faculty - Attendance
  // ---------------------------------------------------------------------------

  static const String markAttendance =
      '/faculty/attendance/mark';

  static const String attendanceHistory =
      '/faculty/attendance/history';

  // ---------------------------------------------------------------------------
  // Faculty - Marks
  // ---------------------------------------------------------------------------

  static const String marksEntry =
      '/faculty/marks/entry';

  static const String marksHistory =
      '/faculty/marks/history';

  // ---------------------------------------------------------------------------
  // Faculty - Results
  // ---------------------------------------------------------------------------

  static const String facultyClassResults =
      '/faculty/results/class';

  // ---------------------------------------------------------------------------
  // Student
  // ---------------------------------------------------------------------------

  static const String student =
      '/student';

  static const String studentDashboard =
      '/student/dashboard';

  static const String studentAttendance =
      '/student/attendance';

  static const String studentFees =
      '/student/fees';

  static const String studentProfile =
      '/student/profile';

  static const String studentResults =
      '/student/results';

  static const String semesterResult =
      '/student/results/semester';

  static const String academicPerformance =
      '/student/results/performance';

  // ---------------------------------------------------------------------------
  // Utility routes
  // ---------------------------------------------------------------------------

  static const String unauthorized =
      '/unauthorized';

  static const String notFound =
      '/404';

  static const String serverError =
      '/server-error';

  // ---------------------------------------------------------------------------
  // Route groups
  // ---------------------------------------------------------------------------

  static const List<String> publicRoutes = [
    root,
    splash,
    login,
    forgotPassword,
  ];

  static const List<String> adminRoutes = [
    admin,
    adminDashboard,
    academicAdmin,
    adminStudents,
    addStudent,
    editStudent,
    studentDetails,
    adminFaculty,
    addFaculty,
    facultyDetails,
    adminDepartments,
    adminSections,
    adminSubjects,
    subjectAssignment,
    adminAttendance,
    attendanceOverview,
    adminExams,
    assessmentSetup,
    marksOverview,
    adminFees,
    feeStructure,
    payment,
    adminGrading,
    gradingPolicy,
    gradeBands,
    adminResults,
    classResults,
    studentResult,
    adminReports,
    classReport,
    studentReport,
  ];

  static const List<String> facultyRoutes = [
    faculty,
    facultyDashboard,
    mySubjects,
    markAttendance,
    attendanceHistory,
    marksEntry,
    marksHistory,
    facultyClassResults,
  ];

  static const List<String> studentRoutes = [
    student,
    studentDashboard,
    studentAttendance,
    studentFees,
    studentProfile,
    studentResults,
    semesterResult,
    academicPerformance,
  ];

  // ---------------------------------------------------------------------------
  // Dynamic route builders
  // ---------------------------------------------------------------------------

  static String editStudentWithId(int studentId) {
    return '$editStudent/$studentId';
  }

  static String studentDetailsWithId(int studentId) {
    return '$studentDetails/$studentId';
  }

  static String facultyDetailsWithId(int facultyId) {
    return '$facultyDetails/$facultyId';
  }

  static String subjectDetailsWithId(int subjectId) {
    return '$adminSubjects/$subjectId';
  }

  static String sectionDetailsWithId(int sectionId) {
    return '$adminSections/$sectionId';
  }

  static String departmentDetailsWithId(int departmentId) {
    return '$adminDepartments/$departmentId';
  }

  static String studentResultWithId(int studentId) {
    return '$studentResult/$studentId';
  }

  static String studentReportWithId(int studentId) {
    return '$studentReport/$studentId';
  }
}