class MarksModel {
  final int? id;
  final int studentId;
  final int assessmentId;
  final double marksObtained;
  final bool isAbsent;
  final bool isLocked;

  const MarksModel({
    this.id,
    required this.studentId,
    required this.assessmentId,
    required this.marksObtained,
    this.isAbsent = false,
    this.isLocked = false,
  });

  factory MarksModel.fromJson(Map<String, dynamic> json) {
    return MarksModel(
      id: _toInt(json['id']),
      studentId:
          _toInt(json['student_id']) ??
          _toInt(json['studentId']) ??
          0,
      assessmentId:
          _toInt(json['assessment_id']) ??
          _toInt(json['assessmentId']) ??
          0,
      marksObtained:
          _toDouble(
            json['marks_obtained'] ??
                json['marksObtained'] ??
                json['marks'],
          ),
      isAbsent:
          json['is_absent'] ??
          json['isAbsent'] ??
          false,
      isLocked:
          json['is_locked'] ??
          json['isLocked'] ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'marks_obtained': marksObtained,
      'is_absent': isAbsent,
      'is_locked': isLocked,
    };
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