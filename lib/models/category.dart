class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map, String documentId) {
    return Category(
      id: documentId, // Теперь id берётся из Firestore, а не из map
      name: map['name'] ?? 'Без названия',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}
