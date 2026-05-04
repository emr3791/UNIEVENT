import 'package:flutter/material.dart';

/// Simple WalletProvider that tracks UNV balance and allows adding/deducting balance.
class WalletProvider with ChangeNotifier {
  double _balance;

  WalletProvider({double initialBalance = 1500.0}) : _balance = initialBalance;

  double get balance => _balance;

  /// Add UNV to the wallet (simulates card purchase)
  void addBalance(double amount) {
    if (amount <= 0) return;
    _balance += amount;
    notifyListeners();
  }

  /// Attempt to deduct amount; returns true if successful.
  bool deduct(double amount) {
    if (amount <= 0) return false;
    if (_balance >= amount) {
      _balance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Purchase helper: returns true if purchase succeeded.
  bool purchase(double price) {
    return deduct(price);
  }
}
