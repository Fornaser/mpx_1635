import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpx_1635/models/media_model.dart';

class SearchService {
  final http.Client _client;

  SearchService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=40',
    );

    final resp = await _client.get(url);
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body);
    final items = (data['items'] as List?) ?? [];

    // Map and filter nulls
    final books = items.map<Book?>((raw) {
      final volumeInfo = (raw['volumeInfo'] as Map?) ?? {};
      final imageLinks = (volumeInfo['imageLinks'] as Map?) ?? {};

      // Skip books without title or description
      final title = volumeInfo['title'] as String?;
      final description = volumeInfo['description'] as String?;
      if (title == null || description == null) return null;

      final authors = (volumeInfo['authors'] as List?)?.cast<String>() ?? ['Unknown Author'];

      // Try OpenLibrary cover
      String coverUrl = '';
      final identifiers = (volumeInfo['industryIdentifiers'] as List?) ?? [];
      for (var identifier in identifiers) {
        final type = identifier['type'] as String?;
        final isbn = identifier['identifier'] as String?;
        if (isbn != null && (type == 'ISBN_13' || type == 'ISBN_10')) {
          coverUrl = 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';
          break;
        }
      }

      // fallback to Google thumbnail
      if (coverUrl.isEmpty) {
        coverUrl = (imageLinks['thumbnail'] as String?) ??
                   (imageLinks['smallThumbnail'] as String?) ?? '';
      }

      if (coverUrl.isEmpty) return null; // skip if no cover

      return Book(
        id: (raw['id'] as String?) ?? '',
        title: title,
        authors: authors,
        synopsis: description,
        coverUrl: _normalizeImageUrl(coverUrl),
      );
    }).whereType<Book>().toList(); // remove nulls

    return books;
  }

  String _normalizeImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://')) {
      return 'https://${url.substring(7)}';
    }
    return url;
  }

  Future<Book?> fetchBookById(String id) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes/$id');
    final resp = await _client.get(url);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return _bookFromVolume(data);
  }

  Book _bookFromVolume(Map<String, dynamic> volume) {
    final volumeInfo = (volume['volumeInfo'] as Map?) ?? {};
    final imageLinks = (volumeInfo['imageLinks'] as Map?) ?? {};

    final title = volumeInfo['title'] as String? ?? 'Unknown Title';
    final description = volumeInfo['description'] as String? ?? '';
    final authors = (volumeInfo['authors'] as List?)?.cast<String>() ?? ['Unknown Author'];
    final coverUrl = (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '').toString();

    return Book(
      id: (volume['id'] as String?) ?? '',
      title: title,
      authors: authors,
      synopsis: description,
      coverUrl: _normalizeImageUrl(coverUrl),
    );
  }
}
