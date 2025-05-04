class Note {
  final String id;
  final String text;
  final String userId;

  Note({
    required this.id,
    required this.text,
    required this.userId,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['_id'],
    text: json['text'],
    userId: json['userId'],
  );
}

