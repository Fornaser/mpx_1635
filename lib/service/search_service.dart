import 'dart:convert';
import 'package:http/http.dart' as http;
import 'author_service.dart';
import '../models/media_model.dart';  
import '../models/author_model.dart';



class BookService {
  final AuthorService _authorService = AuthorService();


  Future searchBooks2({required String searchBook}) async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=$searchBook&maxResults=39"),
      // headers: headers,
    );

    var body = response.body;
    //print(body);
    return body;
  }


  Future<Book> fetchBookDetails(String olid) async {
    final url = Uri.parse("https://openlibrary.org/books/$olid.json");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Book not found");
    }

    final data = jsonDecode(response.body);

    Book baseBook = Book.fromDetailsJson(data, olid);

    List<String> authorNames = [];
    for (String authorKey in baseBook.authors) {
      Author author = await _authorService.fetchAuthor(authorKey);
      authorNames.add(author.name);
    }

    return Book(
      id: baseBook.id,
      title: baseBook.title,
      authors: authorNames,
      synopsis: baseBook.synopsis,
      coverUrl: baseBook.coverUrl,
    );
  }

  Future<List<Book>> fetchFeaturedBooks({String subject = "popular"}) async {
    final url = Uri.parse("https://openlibrary.org/subjects/$subject.json?limit=10");
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final works = data['works'] as List;

    final bookFutures = works.map((work) async {
      try {
        final workKey = work['key'];
        final workId = workKey.replaceAll("/works/", "");
        final workDetailsUrl = Uri.parse("https://openlibrary.org/works/$workId.json");
        final workResponse = await http.get(workDetailsUrl);
        if (workResponse.statusCode != 200) return null;

        final workData = jsonDecode(workResponse.body);

        List<String> authorKeys = (workData['authors'] as List?)
                ?.map<String>((a) => a['author']['key'] as String)
                .toList() ?? [];

        final authors = await Future.wait(authorKeys.map((key) => _authorService.fetchAuthor(key)));
        final authorNames = authors.map((a) => a.name).toList();

        return Book(
          id: workId,
          title: workData['title'] ?? 'Unknown Title',
          authors: authorNames,
          synopsis: workData['description'] is String
              ? workData['description']
              : workData['description']?['value'] ?? '',
          coverUrl: (workData['covers'] != null && workData['covers'].isNotEmpty)
              ? "https://covers.openlibrary.org/b/id/${workData['covers'][0]}-L.jpg"
              : "",
        );
      } catch (_) {
        return null;
      }
    }).toList();

    final books = await Future.wait(bookFutures);
    return books.whereType<Book>().toList();
  }
}