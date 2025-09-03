import 'dart:io';

import 'package:currency_converter/ConcurrenciesData.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'FavouritesProvider.dart';
import 'HistoryProvider.dart';


const apiKey = 'riWukmzDSI42w6v5vjgJfq';

class ConversionProvider with ChangeNotifier {
  double _amount = 0.0;
  String? _fromCurrency;
  String? _toCurrency;
  double _result = 0.0;


  final FavouritesProvider _favouritesProvider;
  final HistoryProvider _historyProvider;

  ConversionProvider(this._favouritesProvider, this._historyProvider);

  List<String> _currencies = CurrencyData.currencies;

  List<String> get currencies => _currencies;
  set currencies(List<String> value){
    _currencies = value;
    notifyListeners();
  }

  double get amount => _amount;
  set amount(double value) {
    _amount = value;
    notifyListeners();
  }

  String? get fromCurrency => _fromCurrency;
  set fromCurrency(String? value) {
    _fromCurrency = value;
    notifyListeners();
  }

  String? get toCurrency => _toCurrency;
  set toCurrency(String? value) {
    _toCurrency = value;
    notifyListeners();
  }

  double get result => _result;
  set result(double value){
    _result = value;
    notifyListeners();
  }


  Future<double?> fetchConversionRate(
      String fromCurrency, String toCurrency) async {

    fromCurrency = fromCurrency.split(' - ')[0];
    toCurrency = toCurrency.split(' - ')[0];
    final url =
        'https://fcsapi.com/api-v2/forex/converter?symbol=$fromCurrency/$toCurrency&access_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) { //verificación de la solicitud HTTP
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true) {  //verificación del estado de la respuesta de la API
          String conversionKey = 'price_1x_$toCurrency';
          if (data['response'].containsKey(conversionKey)) {
            return double.tryParse(data['response'][conversionKey]);
          } else {
            throw Exception(
                'Conversion rate not available for $fromCurrency to $toCurrency');
          }
        } else {
          throw Exception('Conversion rate not available for $fromCurrency to $toCurrency');
        }
      } else {
        throw Exception('Server request error');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet Connection');
      }else{
        throw Exception('$e');
      }

    }
  }

  Future<void> convertCurrency(BuildContext context) async {
    try {
      if (_fromCurrency == null || _toCurrency == null) {
        throw Exception('Currencies not selected');
      }
      // Verificar que las monedas no sean las mismas
      if (_fromCurrency == _toCurrency) {
        throw Exception('Cannot convert to the same currency');
      }

      double? conversionRate = await fetchConversionRate(_fromCurrency!, _toCurrency!);
      if (conversionRate != null) {
        if(_amount > 0.0){
          double convertedAmount = _amount * conversionRate;
          _result = convertedAmount;

          // Guarda la conversión en el historial
          _historyProvider.conversionHistory.add(
            HistoryConversion(
              fromCurrency: _fromCurrency!,
              toCurrency: _toCurrency!,
              amount: _amount,
            ),
          );

          notifyListeners();
        }else{
          if(_amount == -1.0){
            throw Exception('Amount must be a number');
          }else{
            throw Exception('Amount must be higher than 0');
          }

        }

      } else {
        throw Exception('Invalid conversion rate for $_toCurrency');
      }

    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void clearValues() {
    _amount = 0.0;
    _result = 0.0;
    _fromCurrency = null;
    _toCurrency = null;
    _favouritesProvider.isFavorite = false; // Reiniciar el estado de la estrella
    notifyListeners();
  }

  void swapCurrencies() {
    final String? temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    notifyListeners();
  }

  void _showErrorDialog(BuildContext context, String message){
    // set up the button
    Widget okButton = TextButton(
      child: Text('Ok'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

