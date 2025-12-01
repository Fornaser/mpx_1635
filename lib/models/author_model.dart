class Author {
  final String id;      // OL author key, e.g. "OL23919A"
  final String name;

  Author({
    required this.id,
    required this.name,
  });

  factory Author.fromJson(Map<String, dynamic> json, String id) {
    return Author(
      id: id,
      name: json['name'] ?? 'Unknown',
    );
  }
}