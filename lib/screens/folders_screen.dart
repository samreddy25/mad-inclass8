import 'package:flutter/material.dart';
import '../repositories/folder_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final repo = FolderRepository();

  void _refresh() => setState(() {});

  String _titleCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _confirmDelete(int folderId, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Deleting "${_titleCase(name)}" will also delete ALL cards inside it.\n\n(ON DELETE CASCADE)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await repo.deleteFolder(folderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${_titleCase(name)}')));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: FutureBuilder(
        future: repo.getFolders(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final folders = snap.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: folders.length,
            itemBuilder: (context, i) {
              final f = folders[i];
              return FutureBuilder<int>(
                future: repo.getCardCount(f.id!),
                builder: (context, cntSnap) {
                  final count = cntSnap.data ?? 0;

                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardsScreen(folderId: f.id!, folderName: f.folderName),
                          ),
                        );
                        _refresh();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.folder, size: 28),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _confirmDelete(f.id!, f.folderName),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_titleCase(f.folderName), style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text('$count cards'),
                            const Spacer(),
                            const Text('Tap to open →'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}