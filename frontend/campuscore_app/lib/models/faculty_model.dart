class FacultyModel {
  final String id;
  final String name;
  final String employeeId;
  final String department;
  final String designation;

  FacultyModel({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.department,
    required this.designation,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      employeeId: json['employeeId'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
    );
  }
}