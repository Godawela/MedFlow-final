class Note {
  final String id;
  final String text;

  Note({required this.id, required this.text});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}