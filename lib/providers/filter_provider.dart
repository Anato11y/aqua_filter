import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/models/water_analysis.dart';
import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  WaterAnalysis waterAnalysis = getDefaultAnalysis();

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

  List<Category> applyFilters(List<Category> categories) {
    // 🔹 Категории, которые всегда должны оставаться
    List<String> alwaysVisibleCategories = [
      "Фильтры грубой очистки",
      "Фильтры предварительной очистки",
      "Фильтры для дома"
    ];

    return categories.where((category) {
      // ✅ Если категория в списке "обязательных" – показываем её всегда
      if (alwaysVisibleCategories.contains(category.name)) {
        return true;
      }

      // ✅ Оставляем категорию, если хотя бы одно условие выполняется
      if (category.name.contains("ионообмен") &&
          waterAnalysis.hardness >= 3.0) {
        return true; // Если жесткость >= 3.0, категорию оставляем
      }

      if (category.name.contains("безреаген") &&
          (waterAnalysis.turbidity > 5 ||
              waterAnalysis.hydrogenSulfide > 0.003)) {
        return true; // Если мутность >= 5 **или** сероводород >= 0.003, категорию оставляем
      }

      return false; // ❌ Если ни одно условие не выполняется, категорию скрываем
    }).toList();
  }

  void setFilters(WaterAnalysis analysis) {
    waterAnalysis = analysis;
    notifyListeners();
  }

  void resetFilters() {
    waterAnalysis = getDefaultAnalysis();
    notifyListeners();
  }
}
