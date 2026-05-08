import 'package:flutter/material.dart';

// This file was optimized
/* Potential conflicts:
1. Floating point rounding only applies to deduct — addBalance doesn't round. If someone calls addBalance(0.1) ten times they may end up with 1500.9999999999998 instead of 1501.0. Add the same rounding to addBalance if precision matters for displayed balance.
2. canAfford is a new method — no conflicts, purely additive. But make sure any screen currently doing provider.balance >= price manually switches to canAfford() for consistency.
3. initialBalance is not persisted — every hot restart or app relaunch resets to 1500.0. This is expected for mock data but worth flagging before connecting to a real backend.
4. deduct and purchase are separate methods that do the same thing — if a future developer adds logic to deduct (like a transaction log), they need to remember purchase calls it. This is fine as-is but worth documenting in a comment if the codebase grows
*/

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
      // Round to 2 decimal places to avoid floating point drift
      // e.g. 1500.0 - 0.1 - 0.2 can produce 1499.6999999999998
      _balance = double.parse(_balance.toStringAsFixed(2));
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Purchase helper: returns true if purchase succeeded.
  bool purchase(double price) => deduct(price);

  /// Whether the wallet has enough balance for a given price.
  /// Use this in UI to disable buy buttons instead of calling purchase() speculatively.
  bool canAfford(double price) => price > 0 && _balance >= price;
}