class Folder {
  final int? id;
  final String folderName;
  final String timestamp;

  Folder({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'folder_name': folderName,
        'timestamp': timestamp,
      };

  factory Folder.fromMap(Map<String, dynamic> map) => Folder(
        id: map['id'] as int?,
        folderName: map['folder_name'] as String,
        timestamp: map['timestamp'] as String,
      );
}