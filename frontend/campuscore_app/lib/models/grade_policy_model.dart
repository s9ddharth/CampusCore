import 'grade_band_model.dart';

class GradePolicyModel {
  final int? id;
  final String name;
  final String version;
  final double rawScale;
  final double qualifyingThreshold;
  final double teePassMark;
  final int topSCount;
  final bool isActive;
  final List<GradeBandModel> bands;

  const GradePolicyModel({
    this.id,
    required this.name,
    required this.version,
    required this.rawScale,
    required this.qualifyingThreshold,
    required this.teePassMark,
    required this.topSCount,
    required this.isActive,
    required this.bands,
  });

  factory GradePolicyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawBands = json['bands'];

    return GradePolicyModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      rawScale:
          _toDouble(
            json['raw_scale'] ?? json['rawScale'],
          ),
      qualifyingThreshold:
          _toDouble(
            json['qualifying_threshold'] ??
                json['qualifyingThreshold'],
          ),
      teePassMark:
          _toDouble(
            json['tee_pass_mark'] ??
                json['teePassMark'],
          ),
      topSCount:
          _toInt(
            json['top_s_count'] ??
                json['topSCount'],
          ) ??
          5,
      isActive:
          json['is_active'] ??
          json['isActive'] ??
          false,
      bands: rawBands is List
          ? rawBands
              .whereType<Map>()
              .map(
                (item) => GradeBandModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'raw_scale': rawScale,
      'qualifying_threshold': qualifyingThreshold,
      'tee_pass_mark': teePassMark,
      'top_s_count': topSCount,
      'is_active': isActive,
      'bands': bands.map((e) => e.toJson()).toList(),
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