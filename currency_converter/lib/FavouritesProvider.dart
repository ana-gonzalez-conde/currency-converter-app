
import 'package:flutter/material.dart';

class FavouritesProvider with ChangeNotifier {

  bool _isFavorite = false;

  List<FavoriteConversion> _favoriteConversions = [];

  bool get isFavorite => _isFavorite;
  set isFavorite(bool value){
    _isFavorite = value;
    notifyListeners();
  }

  List<FavoriteConversion> get favoriteConversions => _favoriteConversions;

  void removeFavoriteFromIndex(int index) {
    _favoriteConversions.removeAt(index);
    notifyListeners();
  }

  void removeFavoriteFromElement(FavoriteConversion conversion){
    _favoriteConversions.remove(conversion);
    notifyListeners();
  }

  void addFavorite(FavoriteConversion conversion){
    _favoriteConversions.add(conversion);
    notifyListeners();

  }

  void toggleFavorite(BuildContext context, FavoriteConversion conversion) {
    // Crear una instancia de la conversión favorita actual
    try {
      // Verificar si la conversión es de la misma moneda
      if (conversion.fromCurrency == conversion.toCurrency) {
        throw Exception('Cannot add favorite for the same currency');
      }
      // Verificar si la conversión ya está en la lista de favoritos
      if (_favoriteConversions.contains(conversion)) {
        // Si ya está en la lista, eliminarlo
        removeFavoriteFromElement(conversion);
      } else {
        // Si no está en la lista, añadirlo
        addFavorite(conversion);
      }
      _isFavorite = !_isFavorite;
      notifyListeners();
    } catch (e) {
      // Mostrar el AlertDialog en caso de error
      _showErrorDialog(context, e.toString());
    }
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

class FavoriteConversion {
  String fromCurrency;
  String toCurrency;

  FavoriteConversion({
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FavoriteConversion &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency;
  }

  @override
  int get hashCode => fromCurrency.hashCode ^ toCurrency.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
    };
  }
}