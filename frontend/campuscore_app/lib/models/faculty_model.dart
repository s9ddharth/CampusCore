class FacultyDashboardData {
  final int totalStudents;
  final int pendingMarksEntries;
  final List<AssignedSubject> assignedSubjects;
  
  FacultyDashboardData({
    required this.totalStudents,
    required this.pendingMarksEntries,
    required this.assignedSubjects,
  });

  factory FacultyDashboardData.fromJson(Map<String, dynamic> json) {
    return FacultyDashboardData(
      totalStudents: json['totalStudents'] ?? 0,
      pendingMarksEntries: json['pendingMarksEntries'] ?? 0,
      assignedSubjects: (json['assignedSubjects'] as List?)
              ?.map((e) => AssignedSubject.fromJson(e))
              .toList() ?? [],
    );
  }
}

class AssignedSubject {
  final String subjectCode;
  final String name;
  final String section;
  final int studentCount;

  AssignedSubject({
    required this.subjectCode,
    required this.name,
    required this.section,
    required this.studentCount,
  });

  factory AssignedSubject.fromJson(Map<String, dynamic> json) {
    return AssignedSubject(
      subjectCode: json['subjectCode'] ?? '',
      name: json['name'] ?? '',
      section: json['section'] ?? '',
      studentCount: json['studentCount'] ?? 0,
    );
  }
}