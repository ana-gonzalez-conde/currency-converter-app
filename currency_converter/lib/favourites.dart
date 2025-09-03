import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FavouritesProvider.dart';


class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildFavoritesList(context),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    return ListView.builder(
      itemCount: context.watch<FavouritesProvider>().favoriteConversions.length,
      itemBuilder: (context, index) {
        FavoriteConversion conversion = context.watch<FavouritesProvider>().favoriteConversions[index];
        return ListTile(
          title: Text('${conversion.fromCurrency} to ${conversion.toCurrency}'),
          onTap: () {
            _selectFavorite(context, conversion);
          },
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _removeFavorite(context, index);
            },
          ),
        );
      },
    );
  }

  void _removeFavorite(BuildContext context, int index) {
    final removedConversion = context.read<FavouritesProvider>().favoriteConversions[index];
    context.read<FavouritesProvider>().removeFavoriteFromIndex(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Favorite removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectFavorite(BuildContext context, FavoriteConversion conversion) {
    Navigator.pop(context, conversion);
  }

}