// option_provider.dart
import 'package:flutter/material.dart';

class OptionProvider extends ChangeNotifier {
  String _currentOption = "expense"; // Giá trị mặc định

  String get currentOption => _currentOption;

  void updateOption(String newOption) {
    _currentOption = newOption;
    notifyListeners();
  }
}
