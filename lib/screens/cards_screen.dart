import 'package:flutter/material.dart';
import '../models/card_item.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardsScreen({super.key, required this.folderId, required this.folderName});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final repo = CardRepository();

  void _refresh() => setState(() {});

  String _titleCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _img(String path) {
    return Image.asset(
      path,
      width: 52,
      height: 52,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 32),
    );
  }

  Future<void> _deleteCard(CardItem c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('Delete "${_titleCase(c.cardName)} of ${_titleCase(c.suit)}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await repo.deleteCard(c.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card deleted')));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleCase(widget.folderName))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditCardScreen(folderId: widget.folderId, folderName: widget.folderName),
            ),
          );
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: FutureBuilder<List<CardItem>>(
        future: repo.getCardsByFolder(widget.folderId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snap.data!;
          if (cards.isEmpty) return const Center(child: Text('No cards in this folder.'));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = cards[i];

              return ListTile(
                leading: _img(c.imageUrl),
                title: Text('${_titleCase(c.cardName)} of ${_titleCase(c.suit)}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditCardScreen(
                              folderId: widget.folderId,
                              folderName: widget.folderName,
                              existing: c,
                            ),
                          ),
                        );
                        _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteCard(c),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}