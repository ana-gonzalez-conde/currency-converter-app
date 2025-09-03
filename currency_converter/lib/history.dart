import 'package:currency_converter/HistoryProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversion History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildHistoryList(context),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return ListView.builder(
      itemCount: context.watch<HistoryProvider>().conversionHistory.length,
      itemBuilder: (context, index) {
        final conversion = context.watch<HistoryProvider>().conversionHistory[index];
        return ListTile(
          title: Text('${conversion.fromCurrency} to ${conversion.toCurrency}'),
          subtitle: Text('Amount: ${conversion.amount}'),
          onTap: () {
            _selectHistoryItem(context, conversion);
          },
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteHistoryItem(context, index);
            },
          ),
        );
      },
    );
  }

  void _deleteHistoryItem(BuildContext context, int index) {
    final removedConversion = context.read<HistoryProvider>().conversionHistory[index];
    context.read<HistoryProvider>().removeHistoryFromIndex(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectHistoryItem(BuildContext context, HistoryConversion conversion) {
    Navigator.pop(context, conversion);
  }
}