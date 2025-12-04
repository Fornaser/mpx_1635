import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpx_1635/models/media_model.dart';

class SearchService {
  final http.Client _client;
  SearchService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=39',
    );

    final resp = await _client.get(url);
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body);
    final items = (data['items'] as List?) ?? [];

    return items.map<Book>((raw) {
      final volumeInfo = (raw['volumeInfo'] as Map?) ?? {};
      final imageLinks = (volumeInfo['imageLinks'] as Map?) ?? {};
      
      // Extract cover URL using OpenLibrary format when industryIdentifiers exist
      String coverUrl = '';
      final identifiers = (volumeInfo['industryIdentifiers'] as List?) ?? [];
      
      // Try to find ISBN for OpenLibrary cover
      for (var identifier in identifiers) {
        final type = identifier['type'] as String?;
        final isbn = identifier['identifier'] as String?;
        if (isbn != null && (type == 'ISBN_13' || type == 'ISBN_10')) {
          coverUrl = 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';
          break;
        }
      }
      
      // Fallback to Google's thumbnail if no ISBN found
      if (coverUrl.isEmpty) {
        final googleThumb = (imageLinks['thumbnail'] as String?) ?? 
                           (imageLinks['smallThumbnail'] as String?) ?? '';
        coverUrl = _normalizeImageUrl(googleThumb);
      }

      return Book(
        id: (raw['id'] as String?) ?? '',
        title: (volumeInfo['title'] as String?) ?? 'Unknown Title',
        authors: (volumeInfo['authors'] is List)
            ? List<String>.from(volumeInfo['authors'])
            : <String>['Unknown Author'],
        synopsis: (volumeInfo['description'] as String?) ?? '',
        coverUrl: coverUrl,
      );
    }).toList();
  }
  
  Future<Book?> fetchBookById(String id) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes/$id');
    final resp = await _client.get(url);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body);
    return _bookFromVolume(data);
  }

  Book _bookFromVolume(Map<String, dynamic> volume) {
    final volumeInfo = (volume['volumeInfo'] as Map?) ?? {};
    final imageLinks = (volumeInfo['imageLinks'] as Map?) ?? {};

    return Book(
      id: (volume['id'] as String?) ?? '',
      title: (volumeInfo['title'] as String?) ?? 'Unknown Title',
      authors: (volumeInfo['authors'] as List?)?.cast<String>() ?? ['Unknown Author'],
      synopsis: (volumeInfo['description'] as String?) ?? '',
      coverUrl: (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '').toString(),
    );
  }

  String _normalizeImageUrl(String url) {
    if (url.isEmpty) return url;
    // Force https only; avoid modifying query params (zoom/etc) to reduce web image failures (statusCode 0)
    if (url.startsWith('http://')) {
      return 'https://${url.substring(7)}';
    }
    return url;
  }
}
