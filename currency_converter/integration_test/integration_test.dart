import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:currency_converter/main.dart' as app;

class ResultPriceMatcher extends CustomMatcher {
  final double expectedPrice;
  final double tolerance;
  final WidgetTester tester;

  ResultPriceMatcher(this.tester,this.expectedPrice, this.tolerance)
      : super("Widget with price within range", "price", (widget) {
    if (widget is Text) {
      final screenWidth = tester.binding.renderView.size.width;
      final isTablet = screenWidth > 600;
      final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;
      late RegExp resultPattern;
      if (isTablet) {
        if (isLandscape) {
          resultPattern = RegExp(r'^Result: (\d+\.\d+) AFN - Afghan Afghani$');
        } else {
          resultPattern = RegExp(r'^Result: (\d+\.\d+) AFN');
        }
      } else {
        resultPattern = RegExp(r'^Result: (\d+\.\d+) AFN');
      }



      final match = resultPattern.firstMatch(widget.data!);

      if (match != null) {
        final actualPrice = double.parse(match.group(1)!);
        return (actualPrice - expectedPrice).abs() <= tolerance;
      }
    }
    return false;
  });
}



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Función para seleccionar una opción en el menú desplegable
  Future<void> selectOptionFrom(WidgetTester tester, String option) async {
    final dropdown = find.byKey(ValueKey("dropdownFrom"));
    expect(dropdown, findsOneWidget);
    // Abrir el menú desplegable from
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown, warnIfMissed: false);
    await tester.pumpAndSettle();
    final dropdownItem = find.text(option);
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();
  }

  Future<void> selectOptionTo(WidgetTester tester, String option) async {
    final dropdown = find.byKey(ValueKey("dropdownTo"));
    expect(dropdown, findsOneWidget);
    // Abrir el menú desplegable from
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown, warnIfMissed: false);
    await tester.pumpAndSettle();
    final dropdownItem = find.text(option).last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();
  }

  testWidgets("conversion", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;

    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }



    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, '100');
    await tester.pumpAndSettle();

    //CONVERTIR
    final convertButton = find.text('Convert');
    await tester.tap(convertButton);
    await tester.pumpAndSettle();

// Verifica resultado
    final expectedPrice = 73.597;
   final tolerance = 20.0;
    bool resultPriceMatches(Widget widget) {
      return ResultPriceMatcher(tester,expectedPrice, tolerance).matches(widget, {});
    }
    final resultTextFinder = find.byWidgetPredicate(resultPriceMatches);
    expect(resultTextFinder, findsOneWidget);
  });

  testWidgets("Clear button ", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;

    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }

    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, '100');
    await tester.pumpAndSettle();

    // Verificar que los campos estén llenos

    if (isTablet) {
      if (isLandscape) {
        expect(find.text('ALL - Albanian Lek'), findsOneWidget);
        expect(find.text('AFN - Afghan Afghani'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
      } else {
        expect(find.text('ALL'), findsOneWidget);
        expect(find.text('AFN'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
      }
    } else {
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('AFN'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    }


    // Tocar el botón Clear
    final clearButton = find.text('Clear');
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    // Verificar que los campos estén vacíos después de tocar Clear
    if (isTablet) {
      if (isLandscape) {
        expect(find.text('ALL - Albanian Lek'), findsNothing);
        expect(find.text('AFN - Afghan Afghani'), findsNothing);
        expect(find.text('100'), findsNothing);
      } else {
        expect(find.text('ALL'), findsNothing);
        expect(find.text('AFN'), findsNothing);
        expect(find.text('100'), findsNothing);
      }
    } else {
      expect(find.text('ALL'), findsNothing);
      expect(find.text('AFN'), findsNothing);
      expect(find.text('100'), findsNothing);
    }

  });




  testWidgets("Añadir a favoritos", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;
    final isLandscapeMovil = screenWidth < 600 && screenWidth > tester.binding.renderView.size.height;
    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }


    // Añadir a favoritos
    final addToFavoritesButton = find.byIcon(Icons.star_border);
    expect(addToFavoritesButton, findsOneWidget);
    await tester.tap(addToFavoritesButton);
    await tester.pumpAndSettle();

    // Mostrar el menú y seleccionar "Show Favorites"

    if (isTablet) {
        await tester.tap(find.text('Show Favorites'));
        await tester.pumpAndSettle();

    } else {
        if (isLandscapeMovil) {
          await tester.tap(find.text('Show Favorites'));
          await tester.pumpAndSettle();
        }else {
          await tester.tap(find.byIcon(Icons.menu));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Show Favorites'));
          await tester.pumpAndSettle();
        }
    }



    // Verificar que el ítem añadido a favoritos está presente en la pantalla de favoritos
    if (isTablet) {
      if (isLandscape) {
        final favoriteItemFinder = find.text("ALL - Albanian Lek to AFN - Afghan Afghani");
        expect(favoriteItemFinder, findsOneWidget);
      } else {
        final favoriteItemFinder = find.text("ALL to AFN");
        expect(favoriteItemFinder, findsOneWidget);
      }
    } else {
      final favoriteItemFinder = find.text("ALL to AFN");
      expect(favoriteItemFinder, findsOneWidget);
    }




  });

  testWidgets("Añadir a favoritos a misma moneda error", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;

    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester,"ALL - Albanian Lek");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "ALL");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "ALL");
    }

    // Añadir a favoritos
    final addToFavoritesButton = find.byIcon(Icons.star_border);
    expect(addToFavoritesButton, findsOneWidget);
    await tester.tap(addToFavoritesButton);
    await tester.pumpAndSettle();
// Busca el AlertDialog por tipo
    final alertDialogFinder = find.byType(AlertDialog);

// Asegúrate de que solo haya un AlertDialog en el árbol
    expect(alertDialogFinder, findsOneWidget);

    // Encuentra todos los widgets de texto dentro del AlertDialog
    final Iterable<Text> textWidgets = tester.widgetList<Text>(
      find.descendant(of: alertDialogFinder, matching: find.byType(Text)),
    );

    // Asegúrate de que hay tres widgets de texto con los mensajes esperados
    expect(textWidgets.length, 3);

    final String expectedErrorMessage1 = "Error";
    final String expectedErrorMessage2 = "Exception: Cannot add favorite for the same currency";
    final String expectedErrorMessage3 = "Ok";

    expect(textWidgets.elementAt(0).data, expectedErrorMessage1);
    expect(textWidgets.elementAt(1).data, expectedErrorMessage2);
    expect(textWidgets.elementAt(2).data, expectedErrorMessage3);


  });

  testWidgets("Borrar favorito", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;
    final isLandscapeMovil = screenWidth < 600 && screenWidth > tester.binding.renderView.size.height;
    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }
    // Añadir a favoritos
    final addToFavoritesButton = find.byIcon(Icons.star_border);
    expect(addToFavoritesButton, findsOneWidget);
    await tester.tap(addToFavoritesButton);
    await tester.pumpAndSettle();

    // Mostrar el menú y seleccionar "Show Favorites"
    if (isTablet) {
      await tester.tap(find.text('Show Favorites'));
      await tester.pumpAndSettle();

    } else {
      if (isLandscapeMovil) {
        await tester.tap(find.text('Show Favorites'));
        await tester.pumpAndSettle();
      }else {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Show Favorites'));
        await tester.pumpAndSettle();
      }
    }


    // Encontrar el ícono de la papelera y tocarlo para borrar el favorito
    final deleteIcon = find.byIcon(Icons.delete);
    expect(deleteIcon, findsOneWidget);
    await tester.ensureVisible(deleteIcon);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

    // Verificar que la conversión favorita ya no se muestra en la pantalla de favoritos
    expect(
      find.descendant(
        of: find.widgetWithIcon(Icon, Icons.star),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });

  testWidgets("Borrar historial", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;
    final isLandscapeMovil = screenWidth < 600 && screenWidth > tester.binding.renderView.size.height;
    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }
    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, '100');
    await tester.pumpAndSettle();

    //CONVERTIR
    final convertButton = find.text('Convert');
    await tester.tap(convertButton);
    await tester.pumpAndSettle();

    // Mostrar el menú y seleccionar historial
    if (isTablet) {
      await tester.tap(find.text('Show History'));
      await tester.pumpAndSettle();

    } else {
      if (isLandscapeMovil) {
        await tester.tap(find.text('Show History'));
        await tester.pumpAndSettle();
      }else {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Show History'));
        await tester.pumpAndSettle();
      }
    }


    // Encontrar el ícono de la papelera y tocarlo para borrar el favorito
    final deleteIcon = find.byIcon(Icons.delete);
    expect(deleteIcon, findsOneWidget);
    await tester.ensureVisible(deleteIcon);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

// Verify that the history item is deleted
    if (isTablet) {
      if (isLandscape) {
        final historyItemFinder = find.text("ALL - Albanian Lek to AFN - Afghan Afghani: 100.0");
        expect(historyItemFinder, findsNothing);
      } else {
        final historyItemFinder = find.text("ALL to AFN: 100.0");
        expect(historyItemFinder, findsNothing);
      }
    } else {
      final historyItemFinder = find.text("ALL to AFN: 100.0");
      expect(historyItemFinder, findsNothing);
    }


  });

  testWidgets("Conversion misma moneda", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;

    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester,"ALL - Albanian Lek");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "ALL");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "ALL");
    }

    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, '100');
    await tester.pumpAndSettle();

    //CONVERTIR
    final convertButton = find.text('Convert');
    await tester.tap(convertButton);
    await tester.pumpAndSettle();
    // Busca el AlertDialog por tipo
    final alertDialogFinder = find.byType(AlertDialog);

// Asegúrate de que solo haya un AlertDialog en el árbol
    expect(alertDialogFinder, findsOneWidget);

    // Encuentra todos los widgets de texto dentro del AlertDialog
    final Iterable<Text> textWidgets = tester.widgetList<Text>(
      find.descendant(of: alertDialogFinder, matching: find.byType(Text)),
    );

    // Asegúrate de que hay tres widgets de texto con los mensajes esperados
    expect(textWidgets.length, 3);

    final String expectedErrorMessage1 = "Error";
    final String expectedErrorMessage2 = "Exception: Cannot convert to the same currency";
    final String expectedErrorMessage3 = "Ok";

    expect(textWidgets.elementAt(0).data, expectedErrorMessage1);
    expect(textWidgets.elementAt(1).data, expectedErrorMessage2);
    expect(textWidgets.elementAt(2).data, expectedErrorMessage3);
  });

  testWidgets("Error cuando input no es un número", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;

    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }

    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, 'fdsjlk');
    await tester.pumpAndSettle();

    //CONVERTIR
    final convertButton = find.text('Convert');
    await tester.tap(convertButton);
    await tester.pumpAndSettle();
    // Busca el AlertDialog por tipo
    final alertDialogFinder = find.byType(AlertDialog);

    // Asegúrate de que solo haya un AlertDialog en el árbol
    expect(alertDialogFinder, findsOneWidget);

    // Encuentra todos los widgets de texto dentro del AlertDialog
    final Iterable<Text> textWidgets = tester.widgetList<Text>(
      find.descendant(of: alertDialogFinder, matching: find.byType(Text)),
    );

    // Asegúrate de que hay tres widgets de texto con los mensajes esperados
    expect(textWidgets.length, 3);

    final String expectedErrorMessage1 = "Error";
    final String expectedErrorMessage2 = "Exception: Amount must be a number";
    final String expectedErrorMessage3 = "Ok";

    expect(textWidgets.elementAt(0).data, expectedErrorMessage1);
    expect(textWidgets.elementAt(1).data, expectedErrorMessage2);
    expect(textWidgets.elementAt(2).data, expectedErrorMessage3);

  });


  testWidgets("Error cuando input es menor o igual a 0", (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final screenWidth = tester.binding.renderView.size.width;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > 600 && screenWidth > tester.binding.renderView.size.height;
    final isLandscapeMovil = screenWidth < 600 && screenWidth > tester.binding.renderView.size.height;
    if (isTablet) {
      if (isLandscape) {
        await selectOptionFrom(tester, "ALL - Albanian Lek");
        await selectOptionTo(tester, "AFN - Afghan Afghani");
      } else {
        await selectOptionFrom(tester, "ALL");
        await selectOptionTo(tester, "AFN");
      }
    } else {
      await selectOptionFrom(tester, "ALL");
      await selectOptionTo(tester, "AFN");
    }

    //amount
    final amountTextField = find.byType(TextField);
    await tester.enterText(amountTextField, '-3');
    await tester.pumpAndSettle();

    //CONVERTIR
    final convertButton = find.text('Convert');
    await tester.tap(convertButton);
    await tester.pumpAndSettle();
    // Busca el AlertDialog por tipo
    final alertDialogFinder = find.byType(AlertDialog);

    // Asegúrate de que solo haya un AlertDialog en el árbol
    expect(alertDialogFinder, findsOneWidget);

    // Encuentra todos los widgets de texto dentro del AlertDialog
    final Iterable<Text> textWidgets = tester.widgetList<Text>(
      find.descendant(of: alertDialogFinder, matching: find.byType(Text)),
    );

    // Asegúrate de que hay tres widgets de texto con los mensajes esperados
    expect(textWidgets.length, 3);

    final String expectedErrorMessage1 = "Error";
    final String expectedErrorMessage2 = "Exception: Amount must be higher than 0";
    final String expectedErrorMessage3 = "Ok";

    expect(textWidgets.elementAt(0).data, expectedErrorMessage1);
    expect(textWidgets.elementAt(1).data, expectedErrorMessage2);
    expect(textWidgets.elementAt(2).data, expectedErrorMessage3);

  });



}