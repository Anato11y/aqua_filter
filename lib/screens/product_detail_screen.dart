import 'package:aqua_filter/screens/main_scrin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:aqua_filter/providers/cart_provider.dart';
import 'package:aqua_filter/providers/filter_provider.dart';
import 'package:aqua_filter/utils/constants.dart'; // Импорт словаря размеров баллонов
import 'dart:math' as math;

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0;
  String? selectedLoad;
  List<Map<String, dynamic>> availableLoads = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    quantity = (cartProvider.items[widget.product.id]?['quantity'] ?? 0) as int;

    // Определяем категорию загрузок
    String? loadCategory;
    if (widget.product.categoryId == "Установки ионообменные") {
      loadCategory = "Ионообменные смолы";
    } else if (widget.product.categoryId ==
        "Установки фильтрации безреагентные") {
      loadCategory = "Загрузки осветления и обезжелезивания";
    }

    // Если нашли — получаем варианты
    if (loadCategory != null) {
      _fetchAvailableLoads(loadCategory);
    }

    print('Категория товара: ${widget.product.categoryId}');
  }

  /// Загрузка доступных загрузок + фильтрация + сортировка
  Future<void> _fetchAvailableLoads(String loadCategory) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: loadCategory)
        .get();

    List<Map<String, dynamic>> loads = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        "name": data['name'],
        "price": data['price'],
        "loading": _parseLoading(data['loading']),
        "characteristics": _parseCharacteristics(data['characteristics']),
        "imageUrl": data['imageUrl'] ?? '',
        "description": data['description'] ?? 'Загрузка для фильтра',
        "categoryId": data['categoryId'] ?? 'Загрузка',
        "efficiency": data['efficiency'] ?? 100,
        "mixQuantity": data['mixQuantity'] ?? 1,
      };
    }).toList();

    if (mounted) {
      setState(() {
        // 1) Фильтруем
        availableLoads = loads.where(_filterLoads).toList();

        // 2) Сортируем по общей цене (если нужно)
        String? tankSize = _extractTankSize(
            _parseCharacteristics(widget.product.characteristics));
        if (tankSize != null) {
          availableLoads.sort((a, b) {
            int loadQuantityA = _getLoadQuantity(tankSize, a['loading']);
            int loadQuantityB = _getLoadQuantity(tankSize, b['loading']);
            double totalCostA = (loadQuantityA * (a['price'] ?? 0)).toDouble();
            double totalCostB = (loadQuantityB * (b['price'] ?? 0)).toDouble();
            return totalCostA.compareTo(totalCostB);
          });

          if (availableLoads.isNotEmpty) {
            selectedLoad = availableLoads.first['name'];
          }
        }
      });
    }
  }

  /// Разделённая логика: ионообменные vs безреагентные
  bool _filterLoads(Map<String, dynamic> load) {
    final waterAnalysis =
        Provider.of<FilterProvider>(context, listen: false).waterAnalysis;
    Map<String, String> loadChars =
        _parseCharacteristics(load['characteristics']);

    if (widget.product.categoryId == "Установки ионообменные") {
      // Ионообмен: 4 лимита
      double ironLimit =
          _extractLimit(loadChars["Железо двухвалентное, мг/л, до"]);
      double manganeseLimit = _extractLimit(loadChars["Марганец, мг/л, до"]);
      double hardnessLimit = _extractLimit(loadChars["Жесткость, °Ж, до"]);
      double pmoLimit = _extractLimit(loadChars["ПмО, мг О2/л,"]);

      // Всё <= лимитов
      return (waterAnalysis.iron <= ironLimit) &&
          (waterAnalysis.manganese <= manganeseLimit) &&
          (waterAnalysis.hardness <= hardnessLimit) &&
          (waterAnalysis.pmo <= pmoLimit);
    } else if (widget.product.categoryId ==
        "Установки фильтрации безреагентные") {
      // Безреаг: 3 лимита (Fe, Mn, PmO)
      double ironLimit =
          _extractLimit(loadChars["Железо двухвалентное, мг/л, до"]);
      double manganeseLimit = _extractLimit(loadChars["Марганец, мг/л, до"]);
      double pmoLimit = _extractLimit(loadChars["ПмО, мг О2/л,"]);

      return (waterAnalysis.iron <= ironLimit) &&
          (waterAnalysis.manganese <= manganeseLimit) &&
          (waterAnalysis.pmo <= pmoLimit);
    } else {
      // Другие категории — не фильтруем
      return true;
    }
  }

  /// Преобразуем строку с лимитом в double
  double _extractLimit(String? value) {
    if (value != null && value.isNotEmpty) {
      String numericValue =
          value.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
      return double.tryParse(numericValue) ?? double.infinity;
    }
    return double.infinity;
  }

  /// Расчёт производительности (номинал, макс)
  Map<String, String> calculatePerformance(String tankSize, String? flowRate) {
    if (flowRate == null || !flowRate.contains('-')) {
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    flowRate = flowRate.replaceAll(RegExp(r'[^\d.-]'), '');
    List<String> parts = flowRate.split('-').map((e) => e.trim()).toList();
    if (parts.length < 2) {
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    double minFlow = double.tryParse(parts[0]) ?? 0;
    double maxFlow = double.tryParse(parts[1]) ?? 0;
    if (minFlow == 0 && maxFlow == 0) {
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    double diameter = tankDiameters[tankSize] ?? 0;
    if (diameter == 0) {
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    double radius = diameter * 0.0005;
    double area = math.pi * math.pow(radius, 2);

    double nominalFlow = (minFlow + maxFlow) / 2;
    double nominalPerformance = nominalFlow * area;
    double maxPerformance = maxFlow * area;

    return {
      "nominal": nominalPerformance.toStringAsFixed(1),
      "max": maxPerformance.toStringAsFixed(1),
    };
  }

  /// Расчёт фильтроцикла
  String calculateFilterCycle(Map<String, dynamic> load, String? tankSize) {
    if (tankSize == null) {
      return 'Неизвестно';
    }

    int loadQuantity = _getLoadQuantity(tankSize, load['loading']);
    if (loadQuantity == 0) {
      return 'Неизвестно';
    }

    String loadName = load['name'] ?? '';
    double volumePerBag = _extractVolumeFromName(loadName);
    double totalVolume = volumePerBag * loadQuantity;
    if (totalVolume == 0) {
      return 'Неизвестно';
    }

    Map<String, String> loadChars =
        _parseCharacteristics(load['characteristics']);
    print("📌 Загружаем характеристики загрузки: $loadChars");
    double capacity = _extractCapacity(loadChars);
    print("⚠️ Извлечённая ёмкость: $capacity");

    if (capacity == 0) {
      return 'Неизвестно';
    }
    print('Текущий categoryId: "${widget.product.categoryId}"');
    print('Сравниваем с: "Установки фильтрации безреагентные"');

    final waterAnalysis =
        Provider.of<FilterProvider>(context, listen: false).waterAnalysis;
    double hardness = waterAnalysis.hardness;
    double iron = waterAnalysis.iron ?? 0;
    double manganese = waterAnalysis.manganese ?? 0;
    double turbidity = waterAnalysis.turbidity ?? 0;

    // Ионообмен
    print('Фильтроцикл: categoryId = ${widget.product.categoryId}');

    if (widget.product.categoryId == "Установки ионообменные") {
      print('Обрабатываем ионообмен...');
      if (hardness == 0 && iron == 0 && manganese == 0) {
        return 'Неизвестно';
      }
      double denominator = hardness + 2 * manganese + 1.37 * iron;
      if (denominator == 0) {
        return 'Неизвестно';
      }
      double filterCycle = (capacity * totalVolume) / denominator;
      return filterCycle.toStringAsFixed(1);
    } else if (widget.product.categoryId ==
        "Установки фильтрации безреагентные") {
      print('Обрабатываем безреагент...');
      if (turbidity == 0 && iron == 0 && manganese == 0) {
        return 'Неизвестно';
      }
      double denom = (turbidity / 1.75) + manganese + iron;
      if (denom == 0) {
        return 'Неизвестно';
      }
      double filterCycle = (capacity * totalVolume) / denom;
      return filterCycle.toStringAsFixed(1);
    } else {
      return 'Неизвестно';
    }
  }

  double _extractVolumeFromName(String name) {
    RegExp regex = RegExp(r'(\d+[\.,]?\d*)\s*л', caseSensitive: false);
    Match? match = regex.firstMatch(name);
    if (match != null) {
      String volumeStr = match.group(1)?.replaceAll(',', '.') ?? '0';
      return double.tryParse(volumeStr) ?? 0;
    }
    return 0;
  }

  double _extractCapacity(Map<String, String> characteristics) {
    String? capacityStr = characteristics["Емкость, мг-экв/л"];
    if (capacityStr == null || capacityStr.isEmpty) {
      return 0;
    }
    double val =
        double.tryParse(capacityStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return val;
  }

  Map<String, int> _parseLoading(dynamic loading) {
    if (loading is List) {
      return Map.fromIterable(
        loading,
        key: (item) => item.split(":")[0].trim(),
        value: (item) =>
            int.tryParse(item.split(":")[1].replaceAll(";", "").trim()) ?? 0,
      );
    }
    return {};
  }

  Map<String, String> _parseCharacteristics(dynamic characteristics) {
    if (characteristics is List) {
      return Map.fromIterable(
        characteristics,
        key: (item) => item.split(":")[0].trim(),
        value: (item) =>
            item.split(":").length > 1 ? item.split(":")[1].trim() : '',
      );
    } else if (characteristics is Map) {
      return Map.fromEntries(
        (characteristics as Map).entries.map((entry) {
          String key = entry.key.trim();
          String value = entry.value.toString().trim();
          return MapEntry(key, value);
        }),
      );
    }
    return {};
  }

  String? _extractTankSize(Map<String, String> characteristics) {
    return characteristics["Размер баллона"];
  }

  int _getLoadQuantity(String tankSize, Map<String, int> load) {
    if (load.containsKey(tankSize)) {
      return load[tankSize] ?? 0;
    }
    return 0;
  }

  /// Подсчёт итоговой цены (товар + загрузка)
  double _calculateTotalPrice() {
    double totalPrice = widget.product.price;
    if (selectedLoad != null) {
      var load = availableLoads.firstWhere(
        (l) => l['name'] == selectedLoad,
        orElse: () => {},
      );

      if (load.isNotEmpty) {
        String? tankSize = _extractTankSize(
            _parseCharacteristics(widget.product.characteristics));
        if (tankSize == null) {
          return totalPrice;
        }

        int loadQuantity = _getLoadQuantity(tankSize, load['loading']);
        totalPrice += loadQuantity * (load['price'] ?? 0);
      }
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    Map<String, String> productCharacteristics =
        _parseCharacteristics(widget.product.characteristics);
    String? tankSize = _extractTankSize(productCharacteristics);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartProvider.totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Картинка
              Center(
                child: Image.network(
                  widget.product.imageUrl,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              // Название
              Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Цена
              Text(
                '${_calculateTotalPrice().toStringAsFixed(2)} ₽',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 10),
              // Описание
              ExpansionTile(
                title: const Text(
                  'Описание',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.product.description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Характеристики
              ExpansionTile(
                title: const Text(
                  'Характеристики',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: widget.product.characteristics.map((char) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            char,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // Список доступных загрузок
              if (availableLoads.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Выберите загрузку:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: availableLoads.map((load) {
                        // Скорость потока
                        String? flowRate = load['characteristics'] is Map
                            ? (_parseCharacteristics(load['characteristics'])[
                                    "Скорость потока в режиме фильтрации, м/ч"] ??
                                '')
                            : '';

                        // Рассчитываем производительность (min/max)
                        Map<String, String> performance =
                            calculatePerformance(tankSize ?? '', flowRate);

                        // Фильтроцикл
                        String filterCycleStr =
                            calculateFilterCycle(load, tankSize);
                        double filterCycle = double.tryParse(
                                filterCycleStr.replaceAll(',', '.')) ??
                            0;

                        // Сколько дней
                        final waterAnalysis =
                            Provider.of<FilterProvider>(context, listen: false)
                                .waterAnalysis;
                        double dailyWaterConsumption =
                            waterAnalysis.dailyWaterConsumption ?? 0;
                        int daysBetweenRegenerations = dailyWaterConsumption > 0
                            ? (filterCycle / dailyWaterConsumption).round()
                            : 0;
                        int roundedDays = daysBetweenRegenerations.isFinite
                            ? daysBetweenRegenerations
                            : 0;

                        return RadioListTile(
                          title: Text(
                            "${load['name']} (${load['price']} ₽ x "
                            "${_getLoadQuantity(tankSize ?? '', load['loading'])} меш. = "
                            "${(_getLoadQuantity(tankSize ?? '', load['loading']) * (load['price'] ?? 0)).toStringAsFixed(2)} ₽)\n"
                            "Произв. (ном./макс): ${performance['nominal'] ?? '?'} - ${performance['max'] ?? '?'} м³/ч\n"
                            "Фильтроцикл: $filterCycle л ($roundedDays дней)",
                          ),
                          value: load['name'],
                          groupValue: selectedLoad,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                selectedLoad = value;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      // Кнопка «В КОРЗИНУ»
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton(
            onPressed: () async {
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);

              // Добавляем основной товар
              cartProvider.addItem(widget.product, 1);

              // Добавляем выбранную загрузку (если есть)
              if (selectedLoad != null) {
                var load = availableLoads.firstWhere(
                  (l) => l['name'] == selectedLoad,
                  orElse: () => {},
                );
                if (load.isNotEmpty) {
                  String? tankSize = _extractTankSize(
                      _parseCharacteristics(widget.product.characteristics));
                  if (tankSize != null) {
                    int loadQuantity =
                        _getLoadQuantity(tankSize, load['loading']);
                    if (loadQuantity != 0) {
                      double loadPrice = (load['price'] ?? 0).toDouble();
                      double totalLoadCost = loadQuantity * loadPrice;

                      if (mounted) {
                        Product loadProduct = Product(
                          id: load['name'],
                          name: "${load['name']} (Загрузка)",
                          price: totalLoadCost,
                          imageUrl: load['imageUrl'] ?? '',
                          characteristics:
                              _convertMapToList(load['characteristics'] ?? {}),
                          description:
                              load['description'] ?? 'Загрузка для фильтра',
                          categoryId: load['categoryId'] ?? 'Загрузка',
                          efficiency: 100,
                          mixQuantity: (load['mixQuantity'] ?? 1).toDouble(),
                        );

                        cartProvider.addItem(loadProduct, 1);
                      }
                    }
                  }
                }
              }

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                const Text('В КОРЗИНУ', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  /// Преобразование Map<String, String> в List<String>
  List<String> _convertMapToList(Map<String, String> characteristicsMap) {
    return characteristicsMap.entries
        .map((entry) => "${entry.key}: ${entry.value}")
        .toList();
  }
}
