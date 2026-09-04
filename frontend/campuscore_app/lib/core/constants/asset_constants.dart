class AssetConstants {
  AssetConstants._();

  // ---------------------------------------------------------------------------
  // Base directories
  // ---------------------------------------------------------------------------

  static const String assets = 'assets';

  static const String images = '$assets/images';

  static const String icons = '$assets/icons';

  static const String fonts = '$assets/fonts';

  // ---------------------------------------------------------------------------
  // Application branding
  // ---------------------------------------------------------------------------

  static const String appLogo = '$images/logo.png';

  static const String appLogoLight = '$images/logo_light.png';

  static const String appLogoDark = '$images/logo_dark.png';

  static const String appLogoMark = '$images/logo_mark.png';

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const String loginIllustration =
      '$images/login_illustration.png';

  static const String forgotPasswordIllustration =
      '$images/forgot_password_illustration.png';

  static const String splashBackground =
      '$images/splash_background.png';

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  static const String dashboardIllustration =
      '$images/dashboard_illustration.png';

  static const String emptyDashboard =
      '$images/empty_dashboard.png';

  // ---------------------------------------------------------------------------
  // Student
  // ---------------------------------------------------------------------------

  static const String studentPlaceholder =
      '$images/student_placeholder.png';

  static const String profilePlaceholder =
      '$images/profile_placeholder.png';

  // ---------------------------------------------------------------------------
  // Faculty
  // ---------------------------------------------------------------------------

  static const String facultyPlaceholder =
      '$images/faculty_placeholder.png';

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------

  static const String emptyStudents =
      '$images/empty_students.png';

  static const String emptyFaculty =
      '$images/empty_faculty.png';

  static const String emptySubjects =
      '$images/empty_subjects.png';

  static const String emptyDepartments =
      '$images/empty_departments.png';

  static const String emptySections =
      '$images/empty_sections.png';

  static const String emptyAttendance =
      '$images/empty_attendance.png';

  static const String emptyResults =
      '$images/empty_results.png';

  static const String emptyFees =
      '$images/empty_fees.png';

  static const String emptyReports =
      '$images/empty_reports.png';

  // ---------------------------------------------------------------------------
  // Error / system illustrations
  // ---------------------------------------------------------------------------

  static const String serverError =
      '$images/server_error.png';

  static const String networkError =
      '$images/network_error.png';

  static const String accessDenied =
      '$images/access_denied.png';

  static const String pageNotFound =
      '$images/page_not_found.png';

  // ---------------------------------------------------------------------------
  // Navigation icons
  // ---------------------------------------------------------------------------

  static const String dashboardIcon =
      '$icons/dashboard.svg';

  static const String studentsIcon =
      '$icons/students.svg';

  static const String facultyIcon =
      '$icons/faculty.svg';

  static const String departmentsIcon =
      '$icons/departments.svg';

  static const String sectionsIcon =
      '$icons/sections.svg';

  static const String subjectsIcon =
      '$icons/subjects.svg';

  static const String attendanceIcon =
      '$icons/attendance.svg';

  static const String examsIcon =
      '$icons/exams.svg';

  static const String marksIcon =
      '$icons/marks.svg';

  static const String resultsIcon =
      '$icons/results.svg';

  static const String gradingIcon =
      '$icons/grading.svg';

  static const String feesIcon =
      '$icons/fees.svg';

  static const String reportsIcon =
      '$icons/reports.svg';

  // ---------------------------------------------------------------------------
  // Action icons
  // ---------------------------------------------------------------------------

  static const String addIcon =
      '$icons/add.svg';

  static const String editIcon =
      '$icons/edit.svg';

  static const String deleteIcon =
      '$icons/delete.svg';

  static const String searchIcon =
      '$icons/search.svg';

  static const String filterIcon =
      '$icons/filter.svg';

  static const String downloadIcon =
      '$icons/download.svg';

  static const String uploadIcon =
      '$icons/upload.svg';

  static const String refreshIcon =
      '$icons/refresh.svg';

  static const String settingsIcon =
      '$icons/settings.svg';

  static const String logoutIcon =
      '$icons/logout.svg';

  static const String notificationIcon =
      '$icons/notification.svg';

  // ---------------------------------------------------------------------------
  // Academic icons
  // ---------------------------------------------------------------------------

  static const String bookIcon =
      '$icons/book.svg';

  static const String assignmentIcon =
      '$icons/assignment.svg';

  static const String certificateIcon =
      '$icons/certificate.svg';

  static const String calculatorIcon =
      '$icons/calculator.svg';

  static const String chartIcon =
      '$icons/chart.svg';

  static const String rankingIcon =
      '$icons/ranking.svg';

  static const String gradeIcon =
      '$icons/grade.svg';

  // ---------------------------------------------------------------------------
  // Payment / fee icons
  // ---------------------------------------------------------------------------

  static const String paymentIcon =
      '$icons/payment.svg';

  static const String invoiceIcon =
      '$icons/invoice.svg';

  static const String pendingPaymentIcon =
      '$icons/pending_payment.svg';

  static const String paidIcon =
      '$icons/paid.svg';

  // ---------------------------------------------------------------------------
  // Attendance icons
  // ---------------------------------------------------------------------------

  static const String presentIcon =
      '$icons/present.svg';

  static const String absentIcon =
      '$icons/absent.svg';

  static const String lateIcon =
      '$icons/late.svg';

  static const String excusedIcon =
      '$icons/excused.svg';

  // ---------------------------------------------------------------------------
  // File icons
  // ---------------------------------------------------------------------------

  static const String pdfIcon =
      '$icons/pdf.svg';

  static const String excelIcon =
      '$icons/excel.svg';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String asset(String path) {
    return '$assets/$path';
  }

  static String image(String fileName) {
    return '$images/$fileName';
  }

  static String icon(String fileName) {
    return '$icons/$fileName';
  }
}