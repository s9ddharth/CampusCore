class AttendanceRecordModel {
  final int? id;
  final int studentId;
  final int subjectId;
  final DateTime date;
  final String status;
  final String? remarks;

  const AttendanceRecordModel({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.status,
    this.remarks,
  });

  bool get isPresent => status.toUpperCase() == 'PRESENT';

  factory AttendanceRecordModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceRecordModel(
      id: _toInt(json['id']),
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      subjectId:
          _toInt(json['subject_id']) ??
          _toInt(json['subjectId']) ??
          0,
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'UNKNOWN',
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'date': date.toIso8601String(),
      'status': status,
      'remarks': remarks,
    };
  }
}

class AttendanceSummaryModel {
  final int studentId;
  final int subjectId;
  final int totalClasses;
  final int presentClasses;
  final int absentClasses;
  final double percentage;

  const AttendanceSummaryModel({
    required this.studentId,
    required this.subjectId,
    required this.totalClasses,
    required this.presentClasses,
    required this.absentClasses,
    required this.percentage,
  });

  factory AttendanceSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceSummaryModel(
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      subjectId:
          _toInt(json['subject_id']) ??
          _toInt(json['subjectId']) ??
          0,
      totalClasses:
          _toInt(json['total_classes']) ??
          _toInt(json['totalClasses']) ??
          0,
      presentClasses:
          _toInt(json['present_classes']) ??
          _toInt(json['presentClasses']) ??
          0,
      absentClasses:
          _toInt(json['absent_classes']) ??
          _toInt(json['absentClasses']) ??
          0,
      percentage: _toDouble(json['percentage']),
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}