import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:currency_converter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> selectOptionFrom(WidgetTester tester, String option) async {
    final dropdown = find.byKey(ValueKey("dropdownFrom"));
    expect(dropdown, findsOneWidget);
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
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown, warnIfMissed: false);
    await tester.pumpAndSettle();
    final dropdownItem = find.text(option).last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();
  }

  testWidgets("Error en ausencia de conexión a internet", (WidgetTester tester) async {

    // Construye tu widget principal
    app.main();
    await tester.pumpAndSettle();


    // Esperar a que aparezca el mensaje de error debido a la falta de conexión
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
    final String expectedErrorMessage2 = "Exception: No internet Connection";
    final String expectedErrorMessage3 = "Ok";

    expect(textWidgets.elementAt(0).data, expectedErrorMessage1);
    expect(textWidgets.elementAt(1).data, expectedErrorMessage2);
    expect(textWidgets.elementAt(2).data, expectedErrorMessage3);
  });
}