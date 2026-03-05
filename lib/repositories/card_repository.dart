import '../db/database_helper.dart';
import '../models/card_item.dart';

class CardRepository {
  Future<List<CardItem>> getCardsByFolder(int folderId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
    );
    return rows.map((e) => CardItem.fromMap(e)).toList();
  }

  Future<int> insertCard(CardItem card) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('cards', card.toMap());
  }

  Future<int> updateCard(CardItem card) async {
    final db = await DatabaseHelper.instance.database;
    return db.update('cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteCard(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}