class InformationModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime publishDate;
  final String author;
  final String category;
  final String? location;
  final String? history;
  final String? additionalInfo;

  InformationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishDate,
    required this.author,
    required this.category,
    this.location,
    this.history,
    this.additionalInfo,
  });

  factory InformationModel.fromMap(Map<String, dynamic> map, String id) {
    return InformationModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      publishDate: DateTime.fromMillisecondsSinceEpoch(map['publishDate'] ?? 0),
      author: map['author'] ?? '',
      category: map['category'] ?? 'general',
      location: map['location'],
      history: map['history'],
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'publishDate': publishDate.millisecondsSinceEpoch,
      'author': author,
      'category': category,
      'location': location,
      'history': history,
      'additionalInfo': additionalInfo,
    };
  }
}
