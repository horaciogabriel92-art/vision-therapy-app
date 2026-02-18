import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyProvider with ChangeNotifier {
  static const int maxEnergy = 3;
  int _currentEnergy = 3;
  DateTime? _lastRecharge;

  int get currentEnergy => _currentEnergy;
  bool get hasEnergy => _currentEnergy > 0;

  EnergyProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _currentEnergy = prefs.getInt('energy') ?? 3;
    final lastRechargeStr = prefs.getString('last_recharge');
    if (lastRechargeStr != null) {
      _lastRecharge = DateTime.parse(lastRechargeStr);
      _calculateRecharge();
    }
    notifyListeners();
  }

  void _calculateRecharge() {
    // Lógica simple: recargar todo si pasó un día (placeholder)
    if (_lastRecharge != null) {
      final now = DateTime.now();
      if (now.difference(_lastRecharge!).inHours >= 24) {
        _currentEnergy = maxEnergy;
        _saveState();
      }
    }
  }

  Future<void> consumeEnergy() async {
    if (_currentEnergy > 0) {
      _currentEnergy--;
      if (_currentEnergy < maxEnergy && _lastRecharge == null) {
        _lastRecharge = DateTime.now();
      }
      await _saveState();
      notifyListeners();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('energy', _currentEnergy);
    if (_lastRecharge != null) {
      await prefs.setString('last_recharge', _lastRecharge!.toIso8601String());
    }
  }
}
