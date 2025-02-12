class Category {
  final String id;
  final String name;
  final double ironThreshold;
  final double manganeseThreshold;
  final double hardnessThreshold;
  final double turbidityThreshold;
  final double colorThreshold;
  final double pmoThreshold;
  final String pHThreshold;
  final double nitratesThreshold;
  final double dryResidueThreshold;
  final double alkalinityThreshold;
  final double hydrogenSulfideThreshold;
  final double odorThreshold;
  final double ammoniaThreshold;
  final double chloridesThreshold;
  final double sulfatesThreshold;
  final String waterSource;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.ironThreshold,
    required this.manganeseThreshold,
    required this.hardnessThreshold,
    required this.turbidityThreshold,
    required this.colorThreshold,
    required this.pmoThreshold,
    required this.pHThreshold,
    required this.nitratesThreshold,
    required this.dryResidueThreshold,
    required this.alkalinityThreshold,
    required this.hydrogenSulfideThreshold,
    required this.odorThreshold,
    required this.ammoniaThreshold,
    required this.chloridesThreshold,
    required this.sulfatesThreshold,
    required this.waterSource,
    required this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? 'Без названия',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      ironThreshold:
          (map['ironThreshold'] as num?)?.toDouble() ?? double.infinity,
      manganeseThreshold:
          (map['manganeseThreshold'] as num?)?.toDouble() ?? double.infinity,
      hardnessThreshold:
          (map['hardnessThreshold'] as num?)?.toDouble() ?? double.infinity,
      turbidityThreshold:
          (map['turbidityThreshold'] as num?)?.toDouble() ?? double.infinity,
      colorThreshold:
          (map['colorThreshold'] as num?)?.toDouble() ?? double.infinity,
      pmoThreshold:
          (map['pmoThreshold'] as num?)?.toDouble() ?? double.infinity,
      pHThreshold: map['pHThreshold'] ?? "0-14",
      nitratesThreshold:
          (map['nitratesThreshold'] as num?)?.toDouble() ?? double.infinity,
      dryResidueThreshold:
          (map['dryResidueThreshold'] as num?)?.toDouble() ?? double.infinity,
      alkalinityThreshold:
          (map['alkalinityThreshold'] as num?)?.toDouble() ?? double.infinity,
      hydrogenSulfideThreshold:
          (map['hydrogenSulfideThreshold'] as num?)?.toDouble() ??
              double.infinity,
      odorThreshold:
          (map['odorThreshold'] as num?)?.toDouble() ?? double.infinity,
      ammoniaThreshold:
          (map['ammoniaThreshold'] as num?)?.toDouble() ?? double.infinity,
      chloridesThreshold:
          (map['chloridesThreshold'] as num?)?.toDouble() ?? double.infinity,
      sulfatesThreshold:
          (map['sulfatesThreshold'] as num?)?.toDouble() ?? double.infinity,
      waterSource: map['waterSource'] ?? "Любой",
    );
  }
}
