import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const FilterWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  FilterWidgetState createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Фильтр по категории:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in widget.categories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (isSelected) {
                      setState(() {
                        selectedCategory = isSelected ? category : null;
                        widget.onCategorySelected(selectedCategory ?? '');
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
