import 'package:aqua_filter/models/product_list.dart';
import 'package:aqua_filter/models/product_model.dart';
import 'package:flutter/material.dart';

class FilterAndSortScreen extends StatefulWidget {
  const FilterAndSortScreen({super.key});

  @override
  FilterAndSortScreenState createState() => FilterAndSortScreenState();
}

class FilterAndSortScreenState extends State<FilterAndSortScreen> {
  String? selectedCategory;
  bool isAscending = true;

  void filterProducts(List<Product> products) {
    setState(() {
      productList = products.where((product) {
        if (selectedCategory != null &&
            product.characteristics.join().contains(selectedCategory!)) {
          return true;
        }
        return false;
      }).toList();
    });
  }

  void sortProducts() {
    setState(() {
      productList.sort((a, b) => isAscending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры и сортировка'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                filterProducts(productList);
              });
            },
            items: ['Категория 1', 'Категория 2', 'Категория 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAscending = !isAscending;
                    sortProducts();
                  });
                },
                child: Text(isAscending ? 'По возрастанию' : 'По убыванию'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return ListTile(
                  leading: Image.asset(product.imageUrl, width: 50, height: 50),
                  title: Text(product.name),
                  subtitle: Text('${product.price.toStringAsFixed(2)} ₽'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
