import 'package:aqua_filter/models/category.dart';
import 'package:aqua_filter/models/water_analysis.dart';
import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  /// Текущее состояние анализа воды
  WaterAnalysis waterAnalysis = getDefaultAnalysis();

  /// Получаем значения анализа воды по умолчанию
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
      dailyWaterConsumption: 500.0,
      waterSource: "Водопровод",
      wellDepth: null,
    );
  }

  /// Геттер, позволяющий понять, активны ли фильтры
  bool get hasActiveFilters {
    // Примерная логика: если хоть один из параметров (по которым фильтруем) больше 0 (или дефолтного значения), считаем, что фильтр активен
    return (waterAnalysis.iron > 0) ||
        (waterAnalysis.manganese > 0) ||
        (waterAnalysis.hardness > 0) ||
        (waterAnalysis.pmo > 0) ||
        (waterAnalysis.turbidity > 2.6) ||
        (waterAnalysis.hydrogenSulfide > 0.003);
  }

  /// Применяем фильтры к списку категорий
  List<Category> applyFilters(List<Category> categories) {
    // Категории, которые должны показываться всегда
    List<String> alwaysVisibleCategories = [
      "Фильтры грубой очистки",
      "Фильтры предварительной очистки",
      "Фильтры тонкой очистки"
    ];

    return categories.where((category) {
      // Если категория обязательная - показываем
      if (alwaysVisibleCategories.contains(category.name)) {
        return true;
      }

      // Логика фильтра:
      // 1) Если в названии встречается "ионообмен" и жёсткость >= 3.0
      if (category.name.toLowerCase().contains("ионообмен") &&
          waterAnalysis.hardness >= 3.0) {
        return true;
      }

      // 2) Если в названии "безреаген" и мутность >= 5 или H2S >= 0.003
      if ((category.name.toLowerCase().contains("безреаген") ||
              category.name.toLowerCase().contains("обезжелез")) &&
          (waterAnalysis.turbidity >= 5 ||
              waterAnalysis.hydrogenSulfide > 0.003)) {
        return true;
      }

      // Если ничего не подошло, исключаем
      return false;
    }).toList();
  }

  /// Устанавливаем пользовательские данные анализа
  void setFilters(WaterAnalysis analysis) {
    waterAnalysis = analysis;
    notifyListeners();
  }

  /// Сбрасываем к дефолтному анализу
  void resetFilters() {
    waterAnalysis = getDefaultAnalysis();
    notifyListeners();
  }
}
