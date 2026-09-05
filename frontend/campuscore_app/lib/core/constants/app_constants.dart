class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // Application
  // ---------------------------------------------------------------------------

  static const String appName = 'CampusCore';

  static const String appTagline =
      'Integrated Student Management & Academic Intelligence Platform';

  static const String appVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  static const String userKey = 'current_user';

  static const String userRoleKey = 'user_role';

  static const String userIdKey = 'user_id';

  // ---------------------------------------------------------------------------
  // Roles
  // ---------------------------------------------------------------------------

  static const String adminRole = 'ADMIN';

  static const String facultyRole = 'FACULTY';

  static const String studentRole = 'STUDENT';

  // ---------------------------------------------------------------------------
  // User / Student Status
  // ---------------------------------------------------------------------------

  static const String activeStatus = 'ACTIVE';

  static const String inactiveStatus = 'INACTIVE';

  static const String graduatedStatus = 'GRADUATED';

  static const String suspendedStatus = 'SUSPENDED';

  // ---------------------------------------------------------------------------
  // Attendance Status
  // ---------------------------------------------------------------------------

  static const String presentStatus = 'PRESENT';

  static const String absentStatus = 'ABSENT';

  static const String lateStatus = 'LATE';

  static const String excusedStatus = 'EXCUSED';

  // ---------------------------------------------------------------------------
  // Academic Assessment
  // ---------------------------------------------------------------------------

  static const String cat1Assessment = 'CAT1';

  static const String cat2Assessment = 'CAT2';

  static const String teeAssessment = 'TEE';

  static const String internalAssessment = 'INTERNAL';

  // ---------------------------------------------------------------------------
  // Assessment Limits
  // ---------------------------------------------------------------------------

  static const double cat1MaxMarks = 50.0;

  static const double cat2MaxMarks = 50.0;

  static const double teeMaxMarks = 100.0;

  static const double internalMaxMarks = 20.0;

  static const double rawMaximumMarks =
      cat1MaxMarks +
      cat2MaxMarks +
      teeMaxMarks +
      internalMaxMarks;

  // ---------------------------------------------------------------------------
  // Result / Grading Defaults
  // ---------------------------------------------------------------------------

  static const double defaultGradeScale = 200.0;

  static const double defaultQualifyingThreshold = 80.0;

  static const double defaultTeePassMarks = 40.0;

  static const int defaultTopRankedStudents = 5;

  static const String gradeS = 'S';

  static const String gradeA = 'A';

  static const String gradeB = 'B';

  static const String gradeC = 'C';

  static const String gradeD = 'D';

  static const String gradeE = 'E';

  static const String gradeF = 'F';

  // ---------------------------------------------------------------------------
  // Result States
  // ---------------------------------------------------------------------------

  static const String resultCompleted = 'COMPLETED';

  static const String resultIncomplete = 'INCOMPLETE';

  static const String resultPending = 'PENDING';

  // ---------------------------------------------------------------------------
  // Academic Defaults
  // ---------------------------------------------------------------------------

  static const int minimumSemester = 1;

  static const int maximumSemester = 8;

  static const double minimumCgpa = 0.0;

  static const double maximumCgpa = 10.0;

  static const double minimumGpa = 0.0;

  static const double maximumGpa = 10.0;

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  static const int defaultPage = 1;

  static const int defaultPageSize = 20;

  static const int maximumPageSize = 100;

  // ---------------------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------------------

  static const Duration requestTimeout =
      Duration(seconds: 30);

  static const Duration connectionTimeout =
      Duration(seconds: 15);

  static const Duration receiveTimeout =
      Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Local Storage
  // ---------------------------------------------------------------------------

  static const String themeModeKey = 'theme_mode';

  static const String onboardingCompletedKey =
      'onboarding_completed';

  static const String lastSelectedSemesterKey =
      'last_selected_semester';

  static const String lastSelectedAcademicYearKey =
      'last_selected_academic_year';

  // ---------------------------------------------------------------------------
  // Date / Academic Year
  // ---------------------------------------------------------------------------

  static const String defaultAcademicYearFormat = 'YYYY-YYYY';

  static const String displayDateFormat = 'dd MMM yyyy';

  static const String displayDateTimeFormat =
      'dd MMM yyyy, hh:mm a';

  // ---------------------------------------------------------------------------
  // File / Report
  // ---------------------------------------------------------------------------

  static const String excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  static const String pdfMimeType =
      'application/pdf';

  static const String excelExtension = '.xlsx';

  static const String pdfExtension = '.pdf';

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  static const int minimumPasswordLength = 8;

  static const int maximumNameLength = 100;

  static const int maximumPhoneLength = 15;

  static const int maximumRollNumberLength = 30;

  static const int maximumDepartmentCodeLength = 20;

  static const int maximumSubjectCodeLength = 30;

  // ---------------------------------------------------------------------------
  // UI / General
  // ---------------------------------------------------------------------------

  static const double defaultBorderRadius = 12.0;

  static const double smallBorderRadius = 8.0;

  static const double largeBorderRadius = 16.0;

  static const double defaultPagePadding = 24.0;

  static const double mobilePagePadding = 16.0;

  static const double defaultCardElevation = 1.0;

  // ---------------------------------------------------------------------------
  // Error Messages
  // ---------------------------------------------------------------------------

  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  static const String networkErrorMessage =
      'Unable to connect to the server. Please check your internet connection.';

  static const String unauthorizedMessage =
      'Your session has expired. Please log in again.';

  static const String forbiddenMessage =
      'You do not have permission to perform this action.';

  static const String validationErrorMessage =
      'Please check the entered information.';

  static const String serverErrorMessage =
      'The server encountered an error. Please try again later.';

  // ---------------------------------------------------------------------------
  // Empty States
  // ---------------------------------------------------------------------------

  static const String noStudentsMessage =
      'No students found.';

  static const String noFacultyMessage =
      'No faculty members found.';

  static const String noSubjectsMessage =
      'No subjects found.';

  static const String noDepartmentsMessage =
      'No departments found.';

  static const String noSectionsMessage =
      'No sections found.';

  static const String noResultsMessage =
      'No academic results available.';

  static const String noAttendanceMessage =
      'No attendance records available.';

  static const String noFeesMessage =
      'No fee records available.';

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  static const List<String> userRoles = [
    adminRole,
    facultyRole,
    studentRole,
  ];

  static const List<String> attendanceStatuses = [
    presentStatus,
    absentStatus,
    lateStatus,
    excusedStatus,
  ];

  static const List<String> assessmentTypes = [
    cat1Assessment,
    cat2Assessment,
    teeAssessment,
    internalAssessment,
  ];

  static const List<String> gradeLetters = [
    gradeS,
    gradeA,
    gradeB,
    gradeC,
    gradeD,
    gradeE,
    gradeF,
  ];
}