import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _dark = false;
  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _dark = p.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', _dark);
    notifyListeners();
  }
}