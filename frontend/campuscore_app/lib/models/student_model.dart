class SubjectModel {
  final int? id;
  final String code;
  final String name;
  final double credits;
  final int semester;
  final int? departmentId;

  const SubjectModel({
    this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
    this.departmentId,
  });

  factory SubjectModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SubjectModel(
      id: _toInt(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      credits: _toDouble(json['credits']),
      semester: _toInt(json['semester']) ?? 0,
      departmentId:
          _toInt(json['department_id']) ??
          _toInt(json['departmentId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      'semester': semester,
      'department_id': departmentId,
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