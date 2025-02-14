import 'package:aqua_filter/models/water_analysis.dart';
import 'package:flutter/material.dart';
import 'package:aqua_filter/providers/filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterAnalysisScreen extends StatefulWidget {
  const WaterAnalysisScreen({super.key});

  @override
  State<WaterAnalysisScreen> createState() => _WaterAnalysisScreenState();
}

class _WaterAnalysisScreenState extends State<WaterAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, double> defaultValues = {
    "Железо (мг/л)": 0.3,
    "Марганец (мг/л)": 0.1,
    "Жёсткость (°Ж)": 7,
    "Мутность (ЕМФ)": 2.6,
    "Цветность (град)": 20,
    "ПМо (мг/л)": 5,
    "рН (pH)": 7.5,
    "Нитраты (мг/л)": 45,
    "Сухой остаток (мг/л)": 1000,
    "Щелочность (ммоль/л)": 5,
    "Сероводород (мг/л)": 0.003,
    "Запах (балл)": 2,
    "Амиак (мг/л)": 1.5,
    "Хлориды (мг/л)": 350,
    "Сульфаты (мг/л)": 500
  };

  final Map<String, TextEditingController> controllers = {};
  final TextEditingController residentsController = TextEditingController();
  final TextEditingController systemPerformanceController =
      TextEditingController();
  final TextEditingController dailyConsumptionController =
      TextEditingController();
  final TextEditingController wellDepthController = TextEditingController();

  String waterSource = "Водопровод";

  @override
  void initState() {
    super.initState();
    for (var key in defaultValues.keys) {
      controllers[key] = TextEditingController();
    }
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var key in defaultValues.keys) {
        controllers[key]?.text = prefs.getDouble(key)?.toString() ?? '';
      }
      residentsController.text =
          prefs.getInt("Количество проживающих")?.toString() ?? "2";
      systemPerformanceController.text =
          prefs.getDouble("Производительность системы, м3/ч")?.toString() ??
              "1";
      dailyConsumptionController.text =
          prefs.getDouble("Суточное водопотребление, литров")?.toString() ??
              "500";
      waterSource = prefs.getString("Источник водоснабжения") ?? "Водопровод";
      wellDepthController.text =
          prefs.getDouble("Глубина скважины")?.toString() ?? "";
    });
  }

  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in defaultValues.keys) {
      prefs.setDouble(key, _getValue(key));
    }
    prefs.setInt(
        "Количество проживающих", int.tryParse(residentsController.text) ?? 2);
    prefs.setDouble("Производительность системы, м3/ч",
        double.tryParse(systemPerformanceController.text) ?? 1.0);
    prefs.setDouble("Суточное водопотребление, литров",
        double.tryParse(dailyConsumptionController.text) ?? 500.0);
    prefs.setString("Источник водоснабжения", waterSource);
    if (wellDepthController.text.isNotEmpty) {
      prefs.setDouble(
          "Глубина скважины", double.tryParse(wellDepthController.text) ?? 0.0);
    }
  }

  void _applyFilters() async {
    _formKey.currentState!.save();
    final analysis = WaterAnalysis(
      iron: _getValue("Железо (мг/л)"),
      manganese: _getValue("Марганец (мг/л)"),
      hardness: _getValue("Жёсткость (°Ж)"), // Значение жёсткости
      turbidity: _getValue("Мутность (ЕМФ)"),
      color: _getValue("Цветность (град)"),
      pmo: _getValue("ПМо (мг/л)"),
      pH: _getValue("рН (pH)").toString(),
      nitrates: _getValue("Нитраты (мг/л)"),
      dryResidue: _getValue("Сухой остаток (мг/л)"),
      alkalinity: _getValue("Щелочность (ммоль/л)"),
      hydrogenSulfide: _getValue("Сероводород (мг/л)"),
      odor: _getValue("Запах (балл)"),
      ammonia: _getValue("Амиак (мг/л)"),
      chlorides: _getValue("Хлориды (мг/л)"),
      sulfates: _getValue("Сульфаты (мг/л)"),
      numberOfResidents: int.tryParse(residentsController.text) ?? 2,
      systemPerformance:
          double.tryParse(systemPerformanceController.text) ?? 1.0,
      dailyWaterConsumption:
          double.tryParse(dailyConsumptionController.text) ?? 500.0,
      waterSource: waterSource,
      wellDepth: wellDepthController.text.isNotEmpty
          ? double.tryParse(wellDepthController.text) ?? 0.0
          : null,
    );

    await _saveValues();
    Provider.of<FilterProvider>(context, listen: false).setFilters(analysis);
    Navigator.pop(context, true);
  }

  void _resetToDefault() {
    setState(() {
      controllers.forEach((key, controller) {
        controller.text = "";
      });
      residentsController.text = "";
      systemPerformanceController.text = "";
      dailyConsumptionController.text = "";
      waterSource = "Водопровод";
      wellDepthController.text = "";
    });

    // Сбрасываем фильтры
    Provider.of<FilterProvider>(context, listen: false).resetFilters();
  }

  double _getValue(String key) {
    return double.tryParse(controllers[key]?.text ?? '') ?? defaultValues[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализ воды', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: "Сбросить параметры",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "⚙️ Введите параметры воды",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...defaultValues.keys.map(
                      (key) => _buildNumberField(key, controllers[key]!),
                    ),
                    const Text(
                      "⚙️ Дополнительные параметры",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    _buildNumberField(
                        "Количество проживающих", residentsController),
                    _buildNumberField("Производительность системы, м3/ч",
                        systemPerformanceController),
                    _buildNumberField("Суточное водопотребление, литров",
                        dailyConsumptionController),
                    _buildDropdownField("Источник водоснабжения",
                        ["Водопровод", "Скважина", "Колодец", "Водоем"]),
                    if (waterSource == "Скважина")
                      _buildNumberField(
                          "Глубина скважины, метров", wellDepthController),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text("Применить фильтр",
                          style:
                              TextStyle(color: Colors.white, fontSize: 18)))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
            flex: 2, child: Text(label, style: const TextStyle(fontSize: 16))),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                hintText: defaultValues[label]?.toString(),
                hintStyle: const TextStyle(color: Colors.grey)),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Row(
      children: [
        Expanded(
            flex: 2, child: Text(label, style: const TextStyle(fontSize: 16))),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField(
            decoration: const InputDecoration(),
            value: waterSource,
            items: options
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => waterSource = value as String),
          ),
        ),
      ],
    );
  }
}
