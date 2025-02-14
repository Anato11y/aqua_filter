class WaterAnalysisModel {
  double hardness;
  double ph;
  bool hasIron;
  bool hasChlorine;
  bool hasHeavyMetals;

  WaterAnalysisModel({
    required this.hardness,
    required this.ph,
    this.hasIron = false,
    this.hasChlorine = false,
    this.hasHeavyMetals = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'hardness': hardness,
      'ph': ph,
      'hasIron': hasIron,
      'hasChlorine': hasChlorine,
      'hasHeavyMetals': hasHeavyMetals,
    };
  }
}
