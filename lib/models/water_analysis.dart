class WaterAnalysis {
  final double iron;
  final double manganese;
  final double hardness;
  final double turbidity;
  final double color;
  final double pmo;
  final String pH;
  final double nitrates;
  final double dryResidue;
  final double alkalinity;
  final double hydrogenSulfide;
  final double odor;
  final double ammonia;
  final double chlorides;
  final double sulfates;
  final String waterSource;
  final int numberOfResidents;
  final double systemPerformance;
  final double dailyWaterConsumption;
  final double? wellDepth; // null если не скважина

  WaterAnalysis({
    required this.iron,
    required this.manganese,
    required this.hardness,
    required this.turbidity,
    required this.color,
    required this.pmo,
    required this.pH,
    required this.nitrates,
    required this.dryResidue,
    required this.alkalinity,
    required this.hydrogenSulfide,
    required this.odor,
    required this.ammonia,
    required this.chlorides,
    required this.sulfates,
    required this.waterSource,
    required this.numberOfResidents,
    required this.systemPerformance,
    required this.dailyWaterConsumption,
    this.wellDepth,
  });

  // 🔹 Пороговое значение для фильтрации ионообменных установок
  static const double hardnessThreshold = 3.0;

  /// ✅ **Фабрика для создания объекта по умолчанию (нормы ПДК)**
  factory WaterAnalysis.defaultValues() {
    return WaterAnalysis(
      iron: 0.3,
      manganese: 0.1,
      hardness: 7,
      turbidity: 2.6,
      color: 20,
      pmo: 5,
      pH: '6-9',
      nitrates: 45,
      dryResidue: 1000,
      alkalinity: 5,
      hydrogenSulfide: 0.003,
      odor: 2,
      ammonia: 1.5,
      chlorides: 350,
      sulfates: 500,
      waterSource: 'Водопровод',
      numberOfResidents: 3,
      systemPerformance: 2.5,
      dailyWaterConsumption: 200,
      wellDepth: null,
    );
  }

  /// ✅ **Создание объекта из Map (например, Firebase)**
  factory WaterAnalysis.fromMap(Map<String, dynamic> map) {
    return WaterAnalysis(
      iron: (map['iron'] as num).toDouble(),
      manganese: (map['manganese'] as num).toDouble(),
      hardness: (map['hardness'] as num).toDouble(),
      turbidity: (map['turbidity'] as num).toDouble(),
      color: (map['color'] as num).toDouble(),
      pmo: (map['pmo'] as num).toDouble(),
      pH: map['pH'] as String,
      nitrates: (map['nitrates'] as num).toDouble(),
      dryResidue: (map['dryResidue'] as num).toDouble(),
      alkalinity: (map['alkalinity'] as num).toDouble(),
      hydrogenSulfide: (map['hydrogenSulfide'] as num).toDouble(),
      odor: (map['odor'] as num).toDouble(),
      ammonia: (map['ammonia'] as num).toDouble(),
      chlorides: (map['chlorides'] as num).toDouble(),
      sulfates: (map['sulfates'] as num).toDouble(),
      waterSource: map['waterSource'] as String,
      numberOfResidents: (map['numberOfResidents'] as num).toInt(),
      systemPerformance: (map['systemPerformance'] as num).toDouble(),
      dailyWaterConsumption: (map['dailyWaterConsumption'] as num).toDouble(),
      wellDepth: map['wellDepth'] != null
          ? (map['wellDepth'] as num).toDouble()
          : null,
    );
  }

  /// ✅ **Конвертация в Map (для Firebase)**
  Map<String, dynamic> toMap() {
    return {
      'iron': iron,
      'manganese': manganese,
      'hardness': hardness,
      'turbidity': turbidity,
      'color': color,
      'pmo': pmo,
      'pH': pH,
      'nitrates': nitrates,
      'dryResidue': dryResidue,
      'alkalinity': alkalinity,
      'hydrogenSulfide': hydrogenSulfide,
      'odor': odor,
      'ammonia': ammonia,
      'chlorides': chlorides,
      'sulfates': sulfates,
      'waterSource': waterSource,
      'numberOfResidents': numberOfResidents,
      'systemPerformance': systemPerformance,
      'dailyWaterConsumption': dailyWaterConsumption,
      'wellDepth': wellDepth,
    };
  }
}
