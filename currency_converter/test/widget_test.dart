

import 'package:currency_converter/ConversionProvider.dart';
import 'package:currency_converter/FavouritesProvider.dart';
import 'package:currency_converter/HistoryProvider.dart';
import 'package:currency_converter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

void main() {

  testWidgets('Swap button should swap currencies', (WidgetTester tester) async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(
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
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Mock the initial value of currencies
    final ConversionProvider conversionProvider = Provider.of<ConversionProvider>(tester.element(find.byType(MyHomePage)), listen: false);

    conversionProvider.fromCurrency = 'USD - US Dollar';
    conversionProvider.toCurrency = 'EUR - Euro';

    // Find the swap button and simulate a tap
    final Finder swapButtonFinder = find.byKey(const ValueKey('swap'));
    await tester.tap(swapButtonFinder);
    await tester.pump();

    // Verify that currencies have been swapped
    expect(conversionProvider.fromCurrency, 'EUR - Euro');
    expect(conversionProvider.toCurrency, 'USD - US Dollar');

  });

  testWidgets('Dropdown selections should update ConversionProvider', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Mock the initial value of currencies
    final ConversionProvider conversionProvider = Provider.of<ConversionProvider>(tester.element(find.byType(MyHomePage)), listen: false);

    conversionProvider.fromCurrency = null;
    conversionProvider.toCurrency = null;



    // Open the dropdowns
    final dropdown = find.byKey(ValueKey("dropdownFrom"));
    expect(dropdown, findsOneWidget);
    // Abrir el menú desplegable from
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown, warnIfMissed: false);
    await tester.pumpAndSettle();
    final dropdownItem = find.text('ALL - Albanian Lek');
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    final dropdownto = find.byKey(ValueKey("dropdownTo"));
    expect(dropdownto, findsOneWidget);
    // Abrir el menú desplegable from
    await tester.ensureVisible(dropdownto);
    await tester.tap(dropdownto, warnIfMissed: false);
    await tester.pumpAndSettle();
    final dropdownItemto = find.text('AFN - Afghan Afghani').last;
    await tester.tap(dropdownItemto);
    await tester.pumpAndSettle();

    // Verify that ConversionProvider has been updated
    expect(conversionProvider.fromCurrency, 'ALL - Albanian Lek');
    expect(conversionProvider.toCurrency, 'AFN - Afghan Afghani');
  });

  testWidgets('Toggle favorite icon test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Use tester.widget to get the widget tree and extract the ConversionProvider
    final FavouritesProvider favouritesProvider = Provider.of<FavouritesProvider>(tester.element(find.byType(MyHomePage)), listen: false);

    favouritesProvider.isFavorite=true;
    await tester.pump();

    // Verify that the star icon is yellow
    expect(
      find.byWidgetPredicate(
            (widget) =>
        widget is Icon &&
            widget.icon is IconData &&
            (widget.icon as IconData).codePoint == Icons.star.codePoint &&
            widget.color == Colors.yellow,
      ),
      findsOneWidget,
    );


  });

  testWidgets('Clear button test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Set up test data
    final ConversionProvider conversionProvider = Provider.of<ConversionProvider>(tester.element(find.byType(MyHomePage)), listen: false);

    conversionProvider.amount = 10.0;
    conversionProvider.result = 20.0;

    // Pump the widget tree to rebuild the UI
    await tester.pump();

    // Verify that the initial state is correct
    expect(conversionProvider.amount, 10.0);
    expect(conversionProvider.result, 20.0);

    // Tap on the "Clear" button
    await tester.tap(find.text('Clear'));
    await tester.pump();

    // Verify that the values are cleared
    expect(conversionProvider.amount, 0.0);
    expect(conversionProvider.result, 0.0);
  });

  testWidgets('Find Convert button test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavouritesProvider>(
            create: (_) => FavouritesProvider(),
          ),
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(),
          ),
          ChangeNotifierProvider<ConversionProvider>(
            create: (context) => ConversionProvider(
              Provider.of<FavouritesProvider>(context, listen: false),
              Provider.of<HistoryProvider>(context, listen: false),
            ),
          ),
        ],
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Use tester.widget to get the widget tree and extract the ConversionProvider
    final ConversionProvider conversionProvider =
    Provider.of<ConversionProvider>(tester.element(find.byType(MyHomePage)), listen: false);

    // Verify that the "Convert" button is present
    expect(find.text('Convert'), findsOneWidget);

    // Verify that the "Convert" button is enabled
    final Finder convertButtonFinder = find.widgetWithText(ElevatedButton, 'Convert');
    final ElevatedButton convertButton = tester.widget(convertButtonFinder);
    expect(convertButton.enabled, true);


  });

  testWidgets('TextField', (WidgetTester tester) async {
    // Pump the widget tree
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavouritesProvider>(
            create: (_) => FavouritesProvider(),
          ),
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(),
          ),
          ChangeNotifierProvider<ConversionProvider>(
            create: (context) => ConversionProvider(
              Provider.of<FavouritesProvider>(context, listen: false),
              Provider.of<HistoryProvider>(context, listen: false),
            ),
          ),
        ],
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );

    // Wait for widgets to settle
    await tester.pumpAndSettle();

    expect(find.byType(TextField),findsOneWidget );

  });

  testWidgets('Find Show Favorites test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavouritesProvider>(
            create: (_) => FavouritesProvider(),
          ),
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(),
          ),
          ChangeNotifierProvider<ConversionProvider>(
            create: (context) => ConversionProvider(
              Provider.of<FavouritesProvider>(context, listen: false),
              Provider.of<HistoryProvider>(context, listen: false),
            ),
          ),
        ],
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );


    expect(find.text('Show Favorites'), findsOneWidget);


  });

  testWidgets('Find Show History test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavouritesProvider>(
            create: (_) => FavouritesProvider(),
          ),
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider(),
          ),
          ChangeNotifierProvider<ConversionProvider>(
            create: (context) => ConversionProvider(
              Provider.of<FavouritesProvider>(context, listen: false),
              Provider.of<HistoryProvider>(context, listen: false),
            ),
          ),
        ],
        child: MaterialApp(
          home: const MyHomePage(title: 'Currency Converter'),
        ),
      ),
    );


    expect(find.text('Show History'), findsOneWidget);


  });


  testWidgets('Menu icon test', (WidgetTester tester) async {

    final Size customDeviceSize = Size(360, 500);

    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQueryData(size: customDeviceSize),
            child: MultiProvider(
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
              child: MaterialApp(
                home: const MyHomePage(title: 'Currency Converter'),
              ),
            ),
          );
        },
      ),
    );

    expect(
      find.byKey(const ValueKey('menu')),
      findsOneWidget,
    );


  });


}