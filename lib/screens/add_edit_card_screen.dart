import 'package:flutter/material.dart';
import '../models/card_item.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int folderId;
  final String folderName;
  final CardItem? existing;

  const AddEditCardScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    this.existing,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final repo = CardRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameCtrl;
  late final TextEditingController imageCtrl;

  late String suit;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existing?.cardName ?? '');
    imageCtrl = TextEditingController(text: widget.existing?.imageUrl ?? '');
    suit = widget.existing?.suit ?? widget.folderName;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final card = CardItem(
      id: widget.existing?.id,
      cardName: nameCtrl.text.trim().toLowerCase(), // keep lowercase
      suit: suit.toLowerCase(),
      imageUrl: imageCtrl.text.trim(),
      folderId: widget.folderId,
    );

    try {
      if (widget.existing == null) {
        await repo.insertCard(card);
      } else {
        await repo.updateCard(card);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Card' : 'Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Folder: ${widget.folderName}'),
              const SizedBox(height: 12),

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Card rank (ace, 2, 10, king...)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Card name required' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: suit,
                items: const [
                  DropdownMenuItem(value: 'clubs', child: Text('Clubs')),
                  DropdownMenuItem(value: 'diamonds', child: Text('Diamonds')),
                  DropdownMenuItem(value: 'hearts', child: Text('Hearts')),
                  DropdownMenuItem(value: 'spades', child: Text('Spades')),
                ],
                onChanged: (v) => setState(() => suit = v ?? widget.folderName),
                decoration: const InputDecoration(
                  labelText: 'Suit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image path (assets/cards/ace_of_spades.png)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Image path required' : null,
              ),

              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}