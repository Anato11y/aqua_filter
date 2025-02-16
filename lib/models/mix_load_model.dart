class MixLoad {
  final String name;
  final double maxIron;
  final double maxManganese;
  final double maxHardness;
  final double maxPMO;
  final double pricePerUnit;

  MixLoad({
    required this.name,
    required this.maxIron,
    required this.maxManganese,
    required this.maxHardness,
    required this.maxPMO,
    required this.pricePerUnit,
  });
}

// 🔹 Доступные загрузки с их предельными параметрами
final List<MixLoad> availableMixLoads = [
  MixLoad(
      name: "Fero Soft A",
      maxIron: 12,
      maxManganese: 3,
      maxHardness: 10,
      maxPMO: 10,
      pricePerUnit: 500),
  MixLoad(
      name: "Fero Soft B",
      maxIron: 30,
      maxManganese: 5,
      maxHardness: 15,
      maxPMO: 4,
      pricePerUnit: 700),
  MixLoad(
      name: "Fero Soft L",
      maxIron: 9,
      maxManganese: 1.2,
      maxHardness: 10,
      maxPMO: 3,
      pricePerUnit: 400),
];
