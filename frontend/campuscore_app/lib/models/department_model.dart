class DepartmentModel {
  final String id;
  final String code;
  final String name;
  final String? hodName;

  DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    this.hodName,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      hodName: json['hodName'],
    );
  }
}