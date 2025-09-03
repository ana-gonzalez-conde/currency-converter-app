
import 'package:flutter/material.dart';


class HistoryProvider with ChangeNotifier {

  List<HistoryConversion> _conversionHistory = [];

  List<HistoryConversion> get conversionHistory => _conversionHistory;

  void removeHistoryFromIndex(int index) {
    _conversionHistory.removeAt(index);
    notifyListeners();
  }


}

class HistoryConversion {
  String fromCurrency;
  String toCurrency;
  double amount;

  HistoryConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'amount': amount,
    };
  }
}