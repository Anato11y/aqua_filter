import 'package:aqua_filter/models/water_analysis.dart';
import 'package:aqua_filter/models/category.dart';
import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  WaterAnalysis waterAnalysis = getDefaultAnalysis();
  bool isFilterApplied = false; // 🔹 Отслеживаем, применен ли фильтр

  /// ✅ **Получить объект WaterAnalysis с дефолтными значениями**
  static WaterAnalysis getDefaultAnalysis() {
    return WaterAnalysis(
      iron: 0.3,
      manganese: 0.1,
      hardness: 7,
      turbidity: 2.6,
      color: 20,
      pmo: 5,
      pH: "6-9",
      nitrates: 45,
      dryResidue: 1000,
      alkalinity: 5,
      hydrogenSulfide: 0.003,
      odor: 2,
      ammonia: 1.5,
      chlorides: 350,
      sulfates: 500,
      numberOfResidents: 1,
      systemPerformance: 1.0,
      dailyWaterConsumption: 100.0,
      waterSource: "Водопровод",
      wellDepth: null,
    );
  }

  /// ✅ **Метод обновления анализа воды**
  void setFilters(WaterAnalysis analysis) {
    waterAnalysis = analysis;
    isFilterApplied = true; // 🔹 Фильтр применен
    notifyListeners();
  }

  /// ✅ **Сброс фильтра**
  void resetFilters() {
    waterAnalysis = getDefaultAnalysis();
    isFilterApplied = false; // 🔹 Фильтр сброшен
    notifyListeners();
  }

  /// ✅ **Фильтрация товаров в каталоге**
  List<Category> applyFilters(List<Category> categories) {
    return categories.where((category) {
      return (waterAnalysis.iron <= category.ironThreshold) &&
          (waterAnalysis.manganese <= category.manganeseThreshold) &&
          (waterAnalysis.hardness <= category.hardnessThreshold) &&
          (waterAnalysis.turbidity <= category.turbidityThreshold) &&
          (waterAnalysis.nitrates <= category.nitratesThreshold) &&
          (waterAnalysis.dryResidue <= category.dryResidueThreshold) &&
          (waterAnalysis.alkalinity <= category.alkalinityThreshold) &&
          (waterAnalysis.hydrogenSulfide <=
              category.hydrogenSulfideThreshold) &&
          (waterAnalysis.odor <= category.odorThreshold) &&
          (waterAnalysis.ammonia <= category.ammoniaThreshold) &&
          (waterAnalysis.chlorides <= category.chloridesThreshold) &&
          (waterAnalysis.sulfates <= category.sulfatesThreshold) &&
          (waterAnalysis.waterSource == category.waterSource ||
              category.waterSource == "Любой");
    }).toList();
  }
}
