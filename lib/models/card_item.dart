class CardItem {
  final int? id;
  final String cardName;
  final String suit;
  final String imageUrl;
  final int folderId;

  CardItem({
    this.id,
    required this.cardName,
    required this.suit,
    required this.imageUrl,
    required this.folderId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'card_name': cardName,
        'suit': suit,
        'image_url': imageUrl,
        'folder_id': folderId,
      };

  factory CardItem.fromMap(Map<String, dynamic> map) => CardItem(
        id: map['id'] as int?,
        cardName: map['card_name'] as String,
        suit: map['suit'] as String,
        imageUrl: map['image_url'] as String,
        folderId: map['folder_id'] as int,
      );
}