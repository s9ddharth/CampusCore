class AssessmentModel {
  final int? id;
  final int subjectId;
  final int? sectionId;
  final String type;
  final String name;
  final double maxMarks;
  final DateTime? assessmentDate;
  final bool isLocked;

  const AssessmentModel({
    this.id,
    required this.subjectId,
    this.sectionId,
    required this.type,
    required this.name,
    required this.maxMarks,
    this.assessmentDate,
    this.isLocked = false,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: _toInt(json['id']),
      subjectId:
          _toInt(json['subject_id']) ?? _toInt(json['subjectId']) ?? 0,
      sectionId:
          _toInt(json['section_id']) ?? _toInt(json['sectionId']),
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      maxMarks:
          _toDouble(json['max_marks'] ?? json['maxMarks']),
      assessmentDate: _toDate(
        json['assessment_date'] ?? json['assessmentDate'],
      ),
      isLocked:
          json['is_locked'] ?? json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'section_id': sectionId,
      'type': type,
      'name': name,
      'max_marks': maxMarks,
      'assessment_date': assessmentDate?.toIso8601String(),
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

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}