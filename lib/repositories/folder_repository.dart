import '../db/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  Future<List<Folder>> getFolders() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('folders', orderBy: 'folder_name ASC');
    return rows.map((e) => Folder.fromMap(e)).toList();
  }

  Future<int> getCardCount(int folderId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return (res.first['cnt'] as int?) ?? 0;
  }

  Future<int> deleteFolder(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}