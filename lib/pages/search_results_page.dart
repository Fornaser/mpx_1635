import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/base_page.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/pages/media_page.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_search_result_widget.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late Future<List<Book>> _future;
  final SearchService _service = SearchService();

  @override
  void initState() {
    super.initState();
    _future = _service.searchBooks(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchResultsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      setState(() {
        _future = _service.searchBooks(widget.query);
      });
    }
  }

  void _handleSearch(String q) {
    if (q.trim().isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(query: q)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Search Results',
      appBarColor: const Color.fromARGB(255, 112, 171, 153),
      backgroundColor: const Color.fromARGB(255, 188, 212, 205),
      onSearch: _handleSearch,
      child: FutureBuilder<List<Book>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Image.asset('RemindDbFull.png', height: 96));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final books = snapshot.data ?? const <Book>[];
          if (books.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {

              const maxCardWidth = 200.0;
              final width = constraints.maxWidth;
              int crossAxisCount = (width / maxCardWidth).floor();
              if (crossAxisCount < 2) crossAxisCount = 2;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7, // Slightly taller cells to prevent overflow
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: books.length,
                itemBuilder: (context, i) {
                  final book = books[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MediaPage(book: book)),
                    ),
                    child: BookCard(
                      book: book,
                      onAdd: () {},
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
