import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpx_1635/models/author_model.dart';

class AuthorService {
  Future<Author> fetchAuthor(String authorKey) async {
    final key = authorKey.replaceAll("/authors/", "").replaceAll(".json", "");

    final url = Uri.parse("https://openlibrary.org/authors/$key.json");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return Author(id: key, name: "Unknown");
    }

    final data = jsonDecode(response.body);
    return Author.fromJson(data, key);
  }
}