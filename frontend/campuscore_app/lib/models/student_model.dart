class StudentDashboardData {
  final String name;
  final String rollNumber;
  final String semester;
  final double currentGpa;
  final double cgpa;
  final double attendancePercentage;
  final double feesDue;
  final List<SubjectSummary> recentResults;

  StudentDashboardData({
    required this.name,
    required this.rollNumber,
    required this.semester,
    required this.currentGpa,
    required this.cgpa,
    required this.attendancePercentage,
    required this.feesDue,
    required this.recentResults,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      semester: json['semester'] ?? '',
      currentGpa: (json['currentGpa'] ?? 0.0).toDouble(),
      cgpa: (json['cgpa'] ?? 0.0).toDouble(),
      attendancePercentage: (json['attendancePercentage'] ?? 0.0).toDouble(),
      feesDue: (json['feesDue'] ?? 0.0).toDouble(),
      recentResults: (json['recentResults'] as List?)
              ?.map((e) => SubjectSummary.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SubjectSummary {
  final String subjectCode;
  final String subjectName;
  final String grade;
  final double gradePoint;

  SubjectSummary({
    required this.subjectCode,
    required this.subjectName,
    required this.grade,
    required this.gradePoint,
  });

  factory SubjectSummary.fromJson(Map<String, dynamic> json) {
    return SubjectSummary(
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      grade: json['grade'] ?? 'Pending',
      gradePoint: (json['gradePoint'] ?? 0.0).toDouble(),
    );
  }
}