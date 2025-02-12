import 'package:flutter/material.dart';

class ColorProgressBar extends StatelessWidget {
  final double percentage; // Значение соответствия (0-100)

  const ColorProgressBar({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текст с процентом соответствия
        Text(
          'Соответствие: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        // Контейнер с градиентной шкалой
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100, // Нормализация от 0 до 1
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getColor(percentage)),
          ),
        ),
      ],
    );
  }

  /// Функция для получения цвета в зависимости от процента
  Color _getColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green; // 🟢 Зеленый
    } else if (percentage >= 50) {
      return Colors.orange; // 🟡 Желтый
    } else {
      return Colors.red; // 🔴 Красный
    }
  }
}
