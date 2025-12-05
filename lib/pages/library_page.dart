import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_widget.dart';

class LibraryPage extends StatefulWidget {
  final Playlist playlist;

  const LibraryPage({super.key, required this.playlist});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final SearchService _searchService = SearchService();
  bool loading = true;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    List<Book> loadedBooks = [];

    for (var item in widget.playlist.media) {
      try {
        // item is a Map<String, String>
        final id = item['id'];
        final title = item['title'] ?? '';

        if (id != null && id.isNotEmpty) {
          // Search by Google Books ID
          final results = await _searchService.searchBooks(title);
          final book = results.firstWhere(
            (b) => b.id == id,
            orElse: () => results.isNotEmpty ? results[0] : Book(id: id, title: title, authors: [], synopsis: '', coverUrl: ''),
          );
          loadedBooks.add(book);
        }
      } catch (e) {
        print("Error loading book ${item['title']}: $e");
      }
    }

    if (!mounted) return;
    setState(() {
      books = loadedBooks;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.title), backgroundColor: Colors.grey),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("No books in this playlist."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: books[index],
                      );
                    },
                  ),
                ),
    );
  }
}
