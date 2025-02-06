import 'package:flutter/material.dart';

class BonusSystem {
  double balance = 0;

  void addBonus(double amount) {
    balance += amount;
  }

  void useBonus(double amount) {
    if (balance >= amount) {
      balance -= amount;
    } else {
      debugPrint('Недостаточно бонусов!');
    }
  }
}
