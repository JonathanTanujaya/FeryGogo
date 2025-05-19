class InformationModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishDate;
  final String author;
  final String category;

  InformationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishDate,
    required this.author,
    required this.category,
  });

  factory InformationModel.fromMap(Map<String, dynamic> map, String id) {
    return InformationModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      publishDate: DateTime.fromMillisecondsSinceEpoch(map['publishDate'] ?? 0),
      author: map['author'] ?? '',
      category: map['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'publishDate': publishDate.millisecondsSinceEpoch,
      'author': author,
      'category': category,
    };
  }
}
