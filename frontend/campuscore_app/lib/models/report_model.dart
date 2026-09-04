enum ReportType {
  pdf,
  excel,
}

class ReportRequestModel {
  final int studentId;
  final int? semester;
  final String? academicYear;
  final ReportType type;

  const ReportRequestModel({
    required this.studentId,
    this.semester,
    this.academicYear,
    required this.type,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (semester != null) 'semester': semester,
      if (academicYear != null &&
          academicYear!.trim().isNotEmpty)
        'academic_year': academicYear,
    };
  }
}

class ReportFileModel {
  final String fileName;
  final List<int> bytes;
  final String contentType;

  const ReportFileModel({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });
}