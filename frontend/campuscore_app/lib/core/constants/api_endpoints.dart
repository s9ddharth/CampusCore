class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const String login = '/api/auth/login';
  static const String token = '/api/auth/token';
  static const String me = '/api/auth/me';

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  static const String adminDashboard = '/api/dashboard/admin';
  static const String facultyDashboard = '/api/dashboard/faculty';
  static const String studentDashboard = '/api/dashboard/student';
  static const String myDashboard = '/api/dashboard/me';

  // ---------------------------------------------------------------------------
  // Departments
  // ---------------------------------------------------------------------------

  static const String departments = '/api/departments';

  static String department(int departmentId) {
    return '/api/departments/$departmentId';
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  static const String sections = '/api/sections';

  static String section(int sectionId) {
    return '/api/sections/$sectionId';
  }

  // ---------------------------------------------------------------------------
  // Students
  // ---------------------------------------------------------------------------

  static const String students = '/api/students';

  static String student(int studentId) {
    return '/api/students/$studentId';
  }

  // ---------------------------------------------------------------------------
  // Faculty
  // ---------------------------------------------------------------------------

  static const String faculty = '/api/faculty';

  static String facultyMember(int facultyId) {
    return '/api/faculty/$facultyId';
  }

  // ---------------------------------------------------------------------------
  // Subjects
  // ---------------------------------------------------------------------------

  static const String subjects = '/api/subjects';

  static String subject(int subjectId) {
    return '/api/subjects/$subjectId';
  }

  // Faculty ↔ Subject assignments
  static const String facultySubjects = '/api/faculty-subjects';

  static String facultySubject(int assignmentId) {
    return '/api/faculty-subjects/$assignmentId';
  }

  // ---------------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------------

  static const String attendance = '/api/attendance';

  static const String attendanceMark = '/api/attendance/mark';

  static const String attendanceHistory = '/api/attendance/history';

  static String studentAttendance(int studentId) {
    return '/api/attendance/student/$studentId';
  }

  static String subjectAttendance(int subjectId) {
    return '/api/attendance/subject/$subjectId';
  }

  // ---------------------------------------------------------------------------
  // Assessments / Exams
  // ---------------------------------------------------------------------------

  static const String assessments = '/api/assessments';

  static String assessment(int assessmentId) {
    return '/api/assessments/$assessmentId';
  }

  static const String assessmentLock = '/api/assessments/lock';

  static String assessmentUnlock(int assessmentId) {
    return '/api/assessments/$assessmentId/unlock';
  }

  // ---------------------------------------------------------------------------
  // Marks
  // ---------------------------------------------------------------------------

  static const String marks = '/api/marks';

  static const String marksEntry = '/api/marks/entry';

  static const String marksHistory = '/api/marks/history';

  static String studentMarks(int studentId) {
    return '/api/marks/student/$studentId';
  }

  static String subjectMarks(int subjectId) {
    return '/api/marks/subject/$subjectId';
  }

  // ---------------------------------------------------------------------------
  // Academic Results
  // ---------------------------------------------------------------------------

  static const String calculateResults =
      '/api/academic/results/calculate';

  static String subjectResults(int subjectId) {
    return '/api/academic/results/subject/$subjectId';
  }

  static String studentResults(int studentId) {
    return '/api/academic/results/student/$studentId';
  }

  // ---------------------------------------------------------------------------
  // GPA / CGPA
  // ---------------------------------------------------------------------------

  static const String calculateGpa =
      '/api/academic/gpa/calculate';

  static String studentGpa(int studentId) {
    return '/api/academic/gpa/$studentId';
  }

  static String studentCgpa(int studentId) {
    return '/api/academic/cgpa/$studentId';
  }

  static const String calculateAllGpa =
      '/api/academic/gpa/calculate-all';

  // ---------------------------------------------------------------------------
  // Grade Policy
  // ---------------------------------------------------------------------------

  static const String gradePolicies =
      '/api/grade-policy';

  static const String activeGradePolicy =
      '/api/grade-policy/active';

  static String gradePolicy(int policyId) {
    return '/api/grade-policy/$policyId';
  }

  static String activateGradePolicy(int policyId) {
    return '/api/grade-policy/$policyId/activate';
  }

  // ---------------------------------------------------------------------------
  // Fees
  // ---------------------------------------------------------------------------

  static const String feeStructures =
      '/api/fees/structures';

  static String feeStructure(int feeStructureId) {
    return '/api/fees/structures/$feeStructureId';
  }

  static const String studentFees =
      '/api/fees/student';

  static String studentFee(int studentFeeId) {
    return '/api/fees/student/$studentFeeId';
  }

  static const String payments =
      '/api/fees/payments';

  static String payment(int paymentId) {
    return '/api/fees/payments/$paymentId';
  }

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------

  static String studentResultExcel(int studentId) {
    return '/api/reports/results/$studentId/excel';
  }

  static String studentResultPdf(int studentId) {
    return '/api/reports/results/$studentId/pdf';
  }

  // ---------------------------------------------------------------------------
  // Generic helpers
  // ---------------------------------------------------------------------------

  static String withQuery(
    String endpoint,
    Map<String, dynamic> queryParameters,
  ) {
    if (queryParameters.isEmpty) {
      return endpoint;
    }

    final filtered = queryParameters.entries.where(
      (entry) => entry.value != null,
    );

    final query = filtered.map((entry) {
      return '${Uri.encodeQueryComponent(entry.key)}='
          '${Uri.encodeQueryComponent(entry.value.toString())}';
    }).join('&');

    if (query.isEmpty) {
      return endpoint;
    }

    return '$endpoint?$query';
  }
}