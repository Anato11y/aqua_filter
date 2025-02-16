import 'dart:ui';

const String appName = 'AquaFilter';
const String appLogo = 'assets/images/logo.png';

const Color primaryColor = Color(0xFF0074D9); // Голубой
const Color secondaryColor = Color(0xFF7FDBFF); // Бирюзовый
const Color backgroundColor = Color(0xFFF0F8FF); // Светло-голубой фон

const double defaultPadding = 16.0;

/// Словарь для соответствия размеров баллонов их диаметрам (в мм)
const Map<String, double> tankDiameters = {
  "0817": 210,
  "0835": 210,
  "0844": 213,
  "1035": 260,
  "1044": 260,
  "1054": 260,
  "1248": 310,
  "1252": 310,
  "1344": 335,
  "1354": 335,
  "1465": 360,
  "1665": 410,
};
