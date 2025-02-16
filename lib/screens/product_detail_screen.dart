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
  int quantity = 0; // Текущее количество товара в корзине
  String? selectedLoad; // Выбранная загрузка
  List<Map<String, dynamic>> availableLoads = []; // Доступные загрузки

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    quantity = (cartProvider.items[widget.product.id]?['quantity'] ?? 0) as int;

    // Загружаем доступные загрузки только для определенных категорий товаров
    if (widget.product.categoryId == "Установки ионообменные") {
      _fetchAvailableLoads("Ионообменные смолы");
    } else if (widget.product.categoryId ==
        "Установки фильтрации безреагентные") {
      _fetchAvailableLoads("Загрузки осветления и обезжелезивания");
    }

    print('Категория товара: ${widget.product.categoryId}');
  }

  /// Загрузка доступных загрузок из Firestore
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
        availableLoads = loads.where(_filterLoads).toList();

        // Сортируем загрузки по общей стоимости
        String? tankSize = _extractTankSize(
            _parseCharacteristics(widget.product.characteristics));
        if (tankSize != null) {
          availableLoads.sort((a, b) {
            int loadQuantityA = _getLoadQuantity(tankSize, a['loading']);
            int loadQuantityB = _getLoadQuantity(tankSize, b['loading']);
            double totalCostA = (loadQuantityA * (a['price'] ?? 0)).toDouble();
            double totalCostB = (loadQuantityB * (b['price'] ?? 0)).toDouble();
            print(
                'Сравнение загрузок: ${a['name']} ($totalCostA ₽) vs ${b['name']} ($totalCostB ₽)');
            return totalCostA.compareTo(
                totalCostB); // Сортировка от меньшей к большей стоимости
          });

          // Устанавливаем первую загрузку как выбранную по умолчанию
          if (availableLoads.isNotEmpty) {
            selectedLoad = availableLoads.first['name'];
            print('Выбранная загрузка по умолчанию: $selectedLoad');
          }
        }

        print('Доступные загрузки: $availableLoads');
      });
    }
  }

  /// Расчет номинальной и максимальной производительности
  Map<String, String> calculatePerformance(String tankSize, String? flowRate) {
    print('Расчет производительности для размера баллона: $tankSize');

    if (flowRate == null || !flowRate.contains('-')) {
      print(
          'Ошибка: Некорректный формат скорости потока для размера баллона "$tankSize"');
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    // Очищаем строку от лишних символов (например, ";")
    flowRate = flowRate.replaceAll(RegExp(r'[^\d.-]'), '');

    // Разбиваем скорость потока на минимальную и максимальную
    List<String> flowParts = flowRate.split('-').map((e) => e.trim()).toList();
    if (flowParts.length < 2) {
      print(
          'Ошибка: Скорость потока должна содержать минимум два значения (мин-макс)');
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    double minFlow = double.tryParse(flowParts[0]) ?? 0;
    double maxFlow = double.tryParse(flowParts[1]) ?? 0;

    print('Минимальная скорость потока: $minFlow м/ч');
    print('Максимальная скорость потока: $maxFlow м/ч');

    if (minFlow == 0 && maxFlow == 0) {
      print('Ошибка: Невозможно преобразовать скорость потока в число');
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    // Извлекаем диаметр баллона
    double diameter = tankDiameters[tankSize] ?? 0;
    print('Диаметр баллона: $diameter мм');

    if (diameter == 0) {
      print('Ошибка: Диаметр баллона "$tankSize" не найден в словаре');
      return {"nominal": "Неизвестно", "max": "Неизвестно"};
    }

    // Рассчитываем радиус и площадь поперечного сечения
    double radius = diameter * 0.0005;
    double area = math.pi * math.pow(radius, 2);

    print('Радиус баллона: $radius м');
    print('Площадь поперечного сечения: $area м²');

    // Рассчитываем среднюю скорость потока
    double nominalFlow = (minFlow + maxFlow) / 2;

    // Рассчитываем производительность
    double nominalPerformance = nominalFlow * area;
    double maxPerformance = maxFlow * area;

    print('Номинальная производительность: $nominalPerformance м³/ч');
    print('Максимальная производительность: $maxPerformance м³/ч');

    return {
      "nominal": nominalPerformance.toStringAsFixed(1),
      "max": maxPerformance.toStringAsFixed(1),
    };
  }

  /// Фильтрация загрузок по анализу воды
  bool _filterLoads(Map<String, dynamic> load) {
    final waterAnalysis =
        Provider.of<FilterProvider>(context, listen: false).waterAnalysis;

    Map<String, String> loadChars =
        _parseCharacteristics(load['characteristics']);

    double ironLimit = _extractLimit(loadChars["Железо двухвалентное"]);
    double manganeseLimit = _extractLimit(loadChars["Марганец"]);
    double hardnessLimit = _extractLimit(loadChars["Жесткость"]);
    double pmoLimit = _extractLimit(loadChars["ПмО"]);

    print('Фильтрация загрузки: ${load['name']}');
    print(
        'Анализ воды: железо=${waterAnalysis.iron}, марганец=${waterAnalysis.manganese}, жесткость=${waterAnalysis.hardness}, ПмО=${waterAnalysis.pmo}');
    print(
        'Лимиты загрузки: железо=$ironLimit, марганец=$manganeseLimit, жесткость=$hardnessLimit, ПмО=$pmoLimit');

    return (waterAnalysis.iron <= ironLimit) &&
        (waterAnalysis.manganese <= manganeseLimit) &&
        (waterAnalysis.hardness <= hardnessLimit) &&
        (waterAnalysis.pmo <= pmoLimit);
  }

  /// Извлечение числового значения предельного параметра
  double _extractLimit(String? value) {
    if (value != null && value.isNotEmpty) {
      String numericValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(numericValue) ?? double.infinity;
    }
    return double.infinity;
  }

  /// Парсинг loading (количество загрузки для баллона)
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

  /// Парсинг characteristics в Map
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

  /// Извлечение размера баллона из characteristics
  String? _extractTankSize(Map<String, String> characteristics) {
    return characteristics["Размер баллона"];
  }

  /// Определение количества загрузки на основе размера баллона
  int _getLoadQuantity(String tankSize, Map<String, int> load) {
    if (load.containsKey(tankSize)) {
      return load[tankSize] ?? 0;
    }
    print('Ошибка: Размер баллона "$tankSize" не найден в загрузке');
    return 0;
  }

  /// Пересчет цены с учетом загрузок
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
        print('Размер баллона: $tankSize');

        if (tankSize == null) {
          print('Ошибка: Размер баллона не указан в характеристиках товара');
          return totalPrice; // Возвращаем базовую цену
        }

        int loadQuantity = _getLoadQuantity(tankSize, load['loading']);
        print('Количество загрузки: $loadQuantity');

        if (loadQuantity == 0) {
          print('Ошибка: Количество загрузки для размера "$tankSize" равно 0');
        }

        totalPrice += loadQuantity * (load['price'] ?? 0);
        print('Цена загрузки: ${(load['price'] ?? 0)} ₽');
        print('Общая цена с учетом загрузки: $totalPrice ₽');
      }
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Преобразуем characteristics товара в Map<String, String>
    Map<String, String> productCharacteristics =
        _parseCharacteristics(widget.product.characteristics);

    // Извлекаем размер баллона
    String? tankSize = _extractTankSize(productCharacteristics);
    print('Извлеченный размер баллона: $tankSize');

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
              Center(
                child: Image.network(
                  widget.product.imageUrl,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${_calculateTotalPrice().toStringAsFixed(2)} ₽',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 10),
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
              ExpansionTile(
                title: const Text(
                  'Характеристики',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: widget.product.characteristics
                    .map(
                      (char) => Padding(
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
                      ),
                    )
                    .toList(),
              ),
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
                        // Извлекаем скорость потока из характеристик загрузки
                        String? flowRate = load['characteristics'] is Map
                            ? (_parseCharacteristics(load['characteristics'])[
                                    "Скорость потока в режиме фильтрации, м/ч"] ??
                                '')
                            : '';
                        print(
                            'Скорость потока для загрузки "${load['name']}": $flowRate');

                        // Рассчитываем производительность
                        Map<String, String> performance =
                            calculatePerformance(tankSize ?? '', flowRate);

                        return RadioListTile(
                          title: Text(
                            "${load['name']} (${load['price']} ₽ x "
                            "${_getLoadQuantity(tankSize ?? "", load['loading'])} меш. = "
                            "${(_getLoadQuantity(tankSize ?? "", load['loading']) * (load['price'] ?? 0)).toStringAsFixed(2)} ₽) | "
                            "Произв.: ${performance['nominal'] ?? 'Неизвестно'}-${performance['max'] ?? 'Неизвестно'} м³/ч",
                          ),
                          value: load['name'],
                          groupValue: selectedLoad,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                selectedLoad = value;
                                print('Выбранная загрузка: $selectedLoad');
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

              // Добавляем основной товар в корзину
              cartProvider.addItem(widget.product, 1);
              print(
                  'Основной товар добавлен в корзину: ${widget.product.name}');

              // Если выбрана загрузка, добавляем её в корзину
              if (selectedLoad != null) {
                var load = availableLoads.firstWhere(
                  (l) => l['name'] == selectedLoad,
                  orElse: () => {},
                );

                if (load.isNotEmpty) {
                  String? tankSize = _extractTankSize(
                      _parseCharacteristics(widget.product.characteristics));
                  print('Размер баллона при добавлении в корзину: $tankSize');

                  if (tankSize == null) {
                    print(
                        'Ошибка: Размер баллона не указан в характеристиках товара');
                  } else {
                    int loadQuantity =
                        _getLoadQuantity(tankSize, load['loading']);
                    print(
                        'Количество загрузки при добавлении в корзину: $loadQuantity');

                    if (loadQuantity == 0) {
                      print(
                          'Ошибка: Количество загрузки для размера "$tankSize" равно 0');
                    } else {
                      double loadPrice = (load['price'] ?? 0).toDouble();
                      double totalLoadCost = loadQuantity * loadPrice;

                      if (mounted) {
                        Product loadProduct = Product(
                          id: load[
                              'name'], // Используем название загрузки как ID
                          name: "${load['name']} (Загрузка)",
                          price: totalLoadCost,
                          imageUrl: load['imageUrl'] ?? '',
                          characteristics:
                              _convertMapToList(load['characteristics'] ?? {}),
                          description:
                              load['description'] ?? 'Загрузка для фильтра',
                          categoryId: load['categoryId'] ?? 'Загрузка',
                          efficiency: load['efficiency'] ?? 100,
                          mixQuantity: (load['mixQuantity'] ?? 1).toDouble(),
                        );

                        cartProvider.addItem(loadProduct, 1);
                        print(
                            'Загрузка добавлена в корзину: ${loadProduct.name}');
                      }
                    }
                  }
                }
              }

              // Возврат на MainScreen
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
                print('Переход выполнен на MainScreen');
              }

              if (mounted) {
                print(
                    'Товар добавлен в корзину. Общее количество: ${cartProvider.totalItems}');
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
