import 'package:currency_converter/history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favourites.dart';
import 'ConversionProvider.dart';
import 'FavouritesProvider.dart';
import 'HistoryProvider.dart';
import 'ConcurrenciesData.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FavouritesProvider>(
          create: (_) => FavouritesProvider() ,
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider() ,
        ),
        ChangeNotifierProvider<ConversionProvider>(
          create: (context) =>
            ConversionProvider(Provider.of<FavouritesProvider>(context, listen: false), Provider.of<HistoryProvider>(context, listen: false)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Currency Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _amountController = TextEditingController();


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _amountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (MediaQuery.of(context).size.width >= 600) {
          return _buildTabletLayout(orientation);
        } else {
          return _buildMobileLayout(orientation);
        }
      },
    );
  }
  Widget _buildTabletLayout(Orientation orientation) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildMainContent(orientation),
          ),
          Expanded(
            flex: 1,
            child: _buildDrawerContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContent() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Show Favorites'),
            onTap: () {
              if (MediaQuery.of(context).size.width < 600) {
                Navigator.pop(context); // Cerrar el Drawer antes de navegar
              }
              _showFavorites(context);
            },
          ),
          ListTile(
            title: Text('Show History'),
            onTap: () {
              if (MediaQuery.of(context).size.width < 600) {
                Navigator.pop(context); // Cerrar el Drawer antes de navegar
              }
              _showHistory(context);
            },
          ),
        ],
      ),
    );
  }



  Widget _buildMobileLayout(Orientation orientation) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              key: const ValueKey('menu'),
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: _buildDrawerContent(),
      ),
      body: _buildMainContent(orientation),
    );
  }



  Widget _buildMainContent(Orientation orientation) {
    var dropdownCurrencies =
    MediaQuery.of(context).size.width >= 800? CurrencyData.currencies : CurrencyData.shortCurrencies;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        key: const ValueKey('listView'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From'),
                  DropdownButton<String>(
                    key: const ValueKey('dropdownFrom'),
                    value: context
                        .watch<ConversionProvider>()
                        .fromCurrency,
                    onChanged: (String? newValue) {
                      context.read<FavouritesProvider>().isFavorite = false;
                      context.read<ConversionProvider>().result = 0.0;
                      context.read<ConversionProvider>().amount = 0.0;
                      _amountController.text = '';
                      context
                          .read<ConversionProvider>()
                          .fromCurrency = newValue!;
                      if (context
                          .read<ConversionProvider>()
                          .toCurrency !=
                          null &&
                          context
                              .read<ConversionProvider>()
                              .fromCurrency !=
                              null) {
                        FavoriteConversion favConversion =
                        FavoriteConversion(
                            fromCurrency: context
                                .read<ConversionProvider>()
                                .fromCurrency!,
                            toCurrency: context
                                .read<ConversionProvider>()
                                .toCurrency!);
                        if (context
                            .read<FavouritesProvider>()
                            .favoriteConversions
                            .contains(favConversion)) {
                          context.read<FavouritesProvider>().isFavorite = true;
                        }
                      }
                    },
                    items: dropdownCurrencies
                        .map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Container(
                            width: orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.20 :
                            MediaQuery.of(context).size.width * 0.20
                            ,
                            child: Text(currency)
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                key: const ValueKey('swap'),
                onPressed: () {
                  context.read<ConversionProvider>().swapCurrencies();
                  FavoriteConversion favConversion =
                  FavoriteConversion(
                      fromCurrency: context
                          .read<ConversionProvider>()
                          .fromCurrency!,
                      toCurrency: context
                          .read<ConversionProvider>()
                          .toCurrency!);
                  if (context
                      .read<FavouritesProvider>()
                      .favoriteConversions
                      .contains(favConversion)) {
                    context.read<FavouritesProvider>().isFavorite = true;
                  }else{
                    context.read<FavouritesProvider>().isFavorite = false;
                  }
                  context.read<ConversionProvider>().result = 0.0;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To'),
                  DropdownButton<String>(
                    key: const ValueKey('dropdownTo'),
                    value: context
                        .watch<ConversionProvider>()
                        .toCurrency,
                    onChanged: (String? newValue) {
                      context.read<ConversionProvider>().result = 0.0;
                      context.read<ConversionProvider>().amount = 0.0;
                      _amountController.text = '';
                      context.read<FavouritesProvider>().isFavorite = false;
                      context
                          .read<ConversionProvider>()
                          .toCurrency = newValue!;
                      if (context
                          .read<ConversionProvider>()
                          .toCurrency !=
                          null &&
                          context
                              .read<ConversionProvider>()
                              .fromCurrency !=
                              null) {
                        FavoriteConversion favConversion =
                        FavoriteConversion(
                            fromCurrency: context
                                .read<ConversionProvider>()
                                .fromCurrency!,
                            toCurrency: context
                                .read<ConversionProvider>()
                                .toCurrency!);
                        if (context
                            .read<FavouritesProvider>()
                            .favoriteConversions
                            .contains(favConversion)) {
                          context.read<FavouritesProvider>().isFavorite = true;
                        }
                      }
                    },
                    items: dropdownCurrencies
                        .map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Container(
                          width: orientation == Orientation.portrait ?
                          MediaQuery.of(context).size.width * 0.20 :
                          MediaQuery.of(context).size.width * 0.20
                          ,
                          child: Text(currency)
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    try{
                      double amount = double.parse(value);
                      if (amount < 0) {
                        amount = 0.0;
                      }
                      context.read<ConversionProvider>().amount = amount;
                    }catch (e){
                      context.read<ConversionProvider>().amount = -1.0;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<ConversionProvider>().convertCurrency(context);
                },
                child: const Text('Convert'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<ConversionProvider>().clearValues();
                  _amountController.text = '';
                },
                child: const Text('Clear'),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: context
                    .watch<FavouritesProvider>()
                    .isFavorite
                    ? Icon(Icons.star, color: Colors.yellow)
                    : Icon(Icons.star_border),
                onPressed: () {
                  if (context
                      .read<ConversionProvider>()
                      .fromCurrency !=
                      null &&
                      context
                          .read<ConversionProvider>()
                          .toCurrency !=
                          null) {
                    context.read<FavouritesProvider>().toggleFavorite(context,
                        FavoriteConversion(
                            fromCurrency: context.read<ConversionProvider>().fromCurrency!,
                            toCurrency: context.read<ConversionProvider>().toCurrency!));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Result: ${context
                .watch<ConversionProvider>()
                .result} ${context
                .watch<ConversionProvider>()
                .toCurrency ?? ""}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(),
      ),
    );

    if (result != null && result is FavoriteConversion) {
      setState(() {
        context
            .read<ConversionProvider>()
            .fromCurrency = result.fromCurrency;
        context
            .read<ConversionProvider>()
            .toCurrency = result.toCurrency;
        context
            .read<FavouritesProvider>()
            .isFavorite = true;
        context.read<ConversionProvider>().amount = 0.0;
        _amountController.text = " ";
        context
            .read<ConversionProvider>()
            .result = 0.0;
      });
    }
  }

  void _showHistory(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(),
      ),
    );

    if (result != null && result is HistoryConversion) {
      context.read<ConversionProvider>().fromCurrency = result.fromCurrency;
      context.read<ConversionProvider>().toCurrency = result.toCurrency;
      context.read<ConversionProvider>().amount = result.amount;
      _amountController.text = result.amount.toString();
      context.read<ConversionProvider>().convertCurrency(context);
      FavoriteConversion favoriteConversion =
      FavoriteConversion(fromCurrency: result.fromCurrency, toCurrency: result.toCurrency);
      if (context
          .read<FavouritesProvider>()
          .favoriteConversions
          .contains(favoriteConversion)) {
        context.read<FavouritesProvider>().isFavorite = true;
      }else{
        context.read<FavouritesProvider>().isFavorite = false;
      }
    }
  }
}
