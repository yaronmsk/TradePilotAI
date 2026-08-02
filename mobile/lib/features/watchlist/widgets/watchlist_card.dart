import 'package:flutter/material.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

class WatchlistCard extends StatelessWidget {
  const WatchlistCard({
    required this.controller,
    required this.onSymbolSelected,
    required this.onAddPressed,
    super.key,
  });

  final WatchlistController controller;
  final ValueChanged<String> onSymbolSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final state = controller.state;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add stock',
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _WatchlistError(
                    message: state.errorMessage!,
                    onDismissed: controller.clearError,
                  ),
                ],
                const SizedBox(height: 8),
                if (state.items.isEmpty)
                  _EmptyWatchlist(onAddPressed: onAddPressed)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final isSelected = state.selectedSymbol == item.symbol;

                      return _WatchlistTile(
                        item: item,
                        isSelected: isSelected,
                        onSelected: () {
                          controller.selectSymbol(item.symbol);
                          onSymbolSelected(item.symbol);
                        },
                        onNotificationsPressed: () {
                          controller.toggleNotifications(item.symbol);
                        },
                        onRemovePressed: () {
                          controller.removeItem(item.symbol);
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({
    required this.item,
    required this.isSelected,
    required this.onSelected,
    required this.onNotificationsPressed,
    required this.onRemovePressed,
  });

  final WatchlistItem item;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: onSelected,
      leading: CircleAvatar(
        child: Text(
          item.symbol.characters.first,
          semanticsLabel: '${item.symbol} symbol',
        ),
      ),
      title: Text(
        item.symbol,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: item.displayName == item.symbol ? null : Text(item.displayName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: item.isNotificationsEnabled
                ? 'Disable notifications'
                : 'Enable notifications',
            onPressed: onNotificationsPressed,
            icon: Icon(
              item.isNotificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
          ),
          IconButton(
            tooltip: 'Remove ${item.symbol}',
            onPressed: onRemovePressed,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.bookmark_border, size: 40),
            const SizedBox(height: 12),
            const Text('Your watchlist is empty'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add stock'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistError extends StatelessWidget {
  const _WatchlistError({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Dismiss error',
              onPressed: onDismissed,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
