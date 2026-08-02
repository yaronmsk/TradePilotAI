import 'package:flutter/material.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

class AddStockDialog extends StatefulWidget {
  const AddStockDialog({super.key});

  static Future<WatchlistItem?> show(BuildContext context) {
    return showDialog<WatchlistItem>(
      context: context,
      builder: (_) => const AddStockDialog(),
    );
  }

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final symbol = _symbolController.text.trim().toUpperCase();

    Navigator.of(
      context,
    ).pop(WatchlistItem(symbol: symbol, displayName: symbol));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add stock'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: TextFormField(
            controller: _symbolController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Stock symbol',
              hintText: 'For example: AMD',
            ),
            validator: (value) {
              final symbol = value?.trim() ?? '';

              if (symbol.isEmpty) {
                return 'Enter a stock symbol.';
              }

              if (!RegExp(r'^[A-Za-z0-9.\-]{1,10}$').hasMatch(symbol)) {
                return 'Enter a valid stock symbol.';
              }

              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
