# Diseño software

>!-- ## Notas para el desarrollo de este documento
>En este fichero debeis documentar el diseño software de la práctica.

 >:warning: El diseño en un elemento "vivo". No olvideis actualizarlo
 >a medida que cambia durante la realización de la práctica.

 >:warning: Recordad que el diseño debe separar _vista_ y
 >_estado/modelo_.
	 

>El lenguaje de modelado es UML y debeis usar Mermaid para incluir los
diagramas dentro de este documento. Por ejemplo:

```mermaid
classDiagram
  class Main {
    + runApp()
  }

class MyApp {
    + build(BuildContext) Widget
  }

  class MyHomePage {
    - String title
    + createState() State<MyHomePage>
  }

class MyHomePageState {
    - TextEditingController amountController
    + dispose() void
    + build(BuildContext) Widget
    - buildTabletLayout(Orientation) Widget
    - buildDrawerContent() Widget
    - buildMobileLayout(Orientation) Widget
    - buildMainContent(Orientation) Widget
    - showFavorites(BuildContext) void
    - showHistory(BuildContext) void
  }

  class ConversionProvider {
    - double amount
    - String fromCurrency
    - String toCurrency
    - double result
    - FavouritesProvider favouritesProvider
    - HistoryProvider historyProvider
    - List<String> currencies
    + fetchConversionRate(String, String) Future<double>
    + convertCurrency() Future<void>
    + clearValues() void
    + swapCurrencies() void
    - showErrorDialog(BuildContext, String) void
  }

  class CurrencyData {
    + List<String> currencies
    + List<String> shortCurrencies
}

  class HistoryScreen {
    + build(BuildContext) Widget
    - buildHistoryList(BuildContext) Widget
    - deleteHistoryItem(BuildContext, int) void
    - selectHistoryItem(BuildContext, HistoryConversion) void 
  }

  class HistoryProvider {
    - List<HistoryConversion> conversionHistory
    + removeHistoryFromIndex(int) void
  }

  class HistoryConversion {
    + String fromCurrency
    + String toCurrency
    + double amount
    + toMap() Map<String, dynamic>
  }

  class FavoritesScreen {
    + build(BuildContext) Widget
    - buildFavoritesList(BuildContext) Widget
    - removeFavorite(BuildContext, int)
    - selectFavorite(FavoriteConversion, Conversion)
  }

  class FavouritesProvider {
    - bool isFavorite
    - List<FavoriteConversion> favoriteConversions
    + removeFavoriteFromIndex(int) void
    + removeFavoriteFromElement(FavoriteConversion) void
    + addFavorite(FavoriteConversion) void
    + toggleFavorite(BuildContext, FavoriteConversion) void
    - showErrorDialog(BuildContext, String) void
  }

  class FavoriteConversion {
    + String fromCurrency
    + String toCurrency
    + toMap() Map<String, dynamic>
  }

  Main --o ConversionProvider
  Main --o HistoryProvider
  Main --o FavouritesProvider
  Main --o MyApp

  MyApp --|> StatelessWidget
  MyApp --o MyHomePage

  MyHomePage --|> StatefulWidget

  MyHomePageState --|> MyHomePage
  MyHomePageState --|> State~MyHomePage~
  MyHomePageState --o CurrencyData
  MyHomePageState --o ConversionProvider
  MyHomePageState --o FavouritesProvider
  MyHomePageState --o FavoriteConversion
  MyHomePageState --o FavoritesScreen
  MyHomePageState --o HistoryScreen
  MyHomePageState --o HistoryConversion

  ConversionProvider --|> ChangeNotifier
  ConversionProvider --o CurrencyData
  ConversionProvider --o http
  ConversionProvider --o FavouritesProvider
  ConversionProvider --o HistoryProvider
  ConversionProvider --o HistoryConversion

  HistoryScreen --|> StatelessWidget
  HistoryScreen --o HistoryProvider
  HistoryScreen --o HistoryConversion

  HistoryProvider --|> ChangeNotifier
  HistoryProvider --o HistoryConversion

  FavoritesScreen --|> StatelessWidget
  FavoritesScreen --o FavouritesProvider
  FavoritesScreen --o FavoriteConversion

  FavouritesProvider --|> ChangeNotifier
  FavouritesProvider --o FavoriteConversion

    
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas, convertir divisas, añadir al historial, añadir a favoritos, limpiar campos y eliminar favorito
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider-->>HistoryProvider: Conversión a añadir al historial
    HistoryProvider->>ChangeNotifier: Conversión añadida al historial
    ChangeNotifier->>ConversionProvider: Notificar conversión añadida al historial
    ConversionProvider->>ChangeNotifier: Cambio de valor del resultado
    ChangeNotifier->>Main: Notificar cambio de valor del resultado
    User->>Main: Seleccionar estrella favorito
    Main->>FavouritesProvider: Marcar como favorito
    FavouritesProvider->>ChangeNotifier: Favorito añadido
    ChangeNotifier->>Main: Notificar favorito añadido
    User->>Main: Seleccionar Clear
    Main->>ConversionProvider: Limpiar campos
    ConversionProvider->>FavouritesProvider: Desmarcar favorito
    FavouritesProvider->>ChangeNotifier: Favorito desmarcado
    ChangeNotifier->>ConversionProvider: Notificar favorito desmarcado
    ConversionProvider->>ChangeNotifier: Cambio de valor de los campos
    ChangeNotifier->>Main: Notificar cambio de valor de los campos
    User->>Main: Seleccionar menú lateral
    Main->>User: Mostrar menú lateral
    User->>Main: Seleccionar favoritos
    Main->>Favourites: Vista favoritos
    Favourites->>Main: Mostrar vista favoritos
    User->>Favourites: Seleccionar eliminar favorito
    Favourites->>FavouritesProvider: Eliminar favorito
    FavouritesProvider->>ChangeNotifier: Favorito eliminado
    ChangeNotifier->>Favourites: Notificar favorito eliminado
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error de conexión
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error del servidor
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino para la que no hay factor de conversión
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error por factor de conversión no disponible
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino igual a la de origen
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error por intentar convertir a la misma divisa
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir que no es un número
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error por intentar convertir algo que no es un número
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir menor que 0
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error por intentar convertir valor menor que 0
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y convertir divisas
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider->>Main: Error por divisas no seleccionadas
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas y añadir a favoritos
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant Favourites
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino igual a la divisa de origen
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Seleccionar estrella favorito
    Main->>FavouritesProvider: Marcar como favorito
    FavouritesProvider->>Main: Error por añadir a favoritos conversión entre misma divisa
```
>Diagrama de secuencia que contiene los casos de uso de listar divisas, convertir divisas, añadir al historial y eliminar del historial
```mermaid
sequenceDiagram
    participant Main
    participant ConversionProvider
    participant FavouritesProvider
    participant HistoryProvider
    participant ChangeNotifier
    participant History
    actor User

    User->>Main: Iniciar la aplicación
    Main->>FavouritesProvider: Inicializar el Provider
    Main->>HistoryProvider: Inicializar el Provider
    Main->>ConversionProvider: Inicializar el Provider
    Main->>Main: Inicializar la vista
    User->>Main: Seleccionar divisa de origen
    Main-->>ConversionProvider: Valor divisa de origen
    ConversionProvider->>ChangeNotifier: Cambio de divisa de origen
    ChangeNotifier->>Main: Notificar cambio de divisa de origen
    User->>Main: Seleccionar divisa de destino
    Main-->>ConversionProvider: Valor divisa de destino
    ConversionProvider->>ChangeNotifier: Cambio de divisa de destino
    ChangeNotifier->>Main: Notificar cambio de divisa de destino
    User->>Main: Introducir cantidad a convertir
    Main-->>ConversionProvider: Valor cantidad a convertir
    ConversionProvider->>ChangeNotifier: Cambio de cantidad a convertir
    ChangeNotifier->>Main: Notificar cambio de cantidad a convertir
    User->>Main: Seleccionar convertir
    Main->>ConversionProvider: Convertir cantidad
    ConversionProvider-->>HistoryProvider: Conversión a añadir al historial
    HistoryProvider->>ChangeNotifier: Conversión añadida al historial
    ChangeNotifier->>ConversionProvider: Notificar conversión añadida al historial
    ConversionProvider->>ChangeNotifier: Cambio de valor del resultado
    ChangeNotifier->>Main: Notificar cambio de valor del resultado
    User->>Main: Seleccionar menú lateral
    Main->>User: Mostrar menú lateral
    User->>Main: Seleccionar historial
    Main->>History: Vista historial
    History->>Main: Mostrar vista historial
    User->>History: Seleccionar eliminar del historial
    History->>HistoryProvider: Eliminar del historial
    HistoryProvider->>ChangeNotifier: Elemento eliminado del historial
    ChangeNotifier->>History: Notificar elemento eliminado
```
