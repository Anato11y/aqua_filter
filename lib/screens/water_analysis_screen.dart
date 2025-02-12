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
    "Железоw": 0.3,
    "Марганец": 0.1,
    "Жёсткость": 7,
    "Мутность": 2.6,
    "Цветность": 20,
    "ПМо": 5,
    "рН": 7.5,
    "Нитраты": 45,
    "Сухой остаток": 1000,
    "Щелочность": 5,
    "Сероводород": 0.003,
    "Запах": 2,
    "Амиак": 1.5,
    "Хлориды": 350,
    "Сульфаты": 500
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
          prefs.getDouble("Производительность системы")?.toString() ?? "1";
      dailyConsumptionController.text =
          prefs.getDouble("Суточное водопотребление")?.toString() ?? "500";
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
    prefs.setDouble("Производительность системы",
        double.tryParse(systemPerformanceController.text) ?? 1.0);
    prefs.setDouble("Суточное водопотребление",
        double.tryParse(dailyConsumptionController.text) ?? 500.0);
    prefs.setString("Источник водоснабжения", waterSource);
    if (wellDepthController.text.isNotEmpty) {
      prefs.setDouble(
          "Глубина скважины", double.tryParse(wellDepthController.text) ?? 0.0);
    }
  }

  void _resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
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
    // 🔹 Очищаем SharedPreferences
    await prefs.clear();
  }

  void _applyFilters() async {
    _formKey.currentState!.save();

    final analysis = WaterAnalysis(
      iron: _getValue("Железо"),
      manganese: _getValue("Марганец"),
      hardness: _getValue("Жёсткость"),
      turbidity: _getValue("Мутность"),
      color: _getValue("Цветность"),
      pmo: _getValue("ПМо"),
      pH: _getValue("рН").toString(),
      nitrates: _getValue("Нитраты"),
      dryResidue: _getValue("Сухой остаток"),
      alkalinity: _getValue("Щелочность"),
      hydrogenSulfide: _getValue("Сероводород"),
      odor: _getValue("Запах"),
      ammonia: _getValue("Амиак"),
      chlorides: _getValue("Хлориды"),
      sulfates: _getValue("Сульфаты"),
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
                    ...defaultValues.keys.map(
                      (key) => _buildNumberField(key, controllers[key]!),
                    ),
                    _buildNumberField(
                        "Количество проживающих", residentsController),
                    _buildNumberField("Производительность системы",
                        systemPerformanceController),
                    _buildNumberField(
                        "Суточное водопотребление", dailyConsumptionController),
                    _buildDropdownField("Источник водоснабжения",
                        ["Водопровод", "Скважина", "Колодец", "Водоем"]),
                    if (waterSource == "Скважина")
                      _buildNumberField(
                          "Глубина скважины", wellDepthController),
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
