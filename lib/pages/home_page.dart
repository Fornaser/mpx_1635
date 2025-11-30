import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/base_page.dart';
import 'package:mpx_1635/pages/search_results.dart';
import 'package:mpx_1635/service/book_service.dart';
import 'package:mpx_1635/widgets/book_carousel.dart';
import 'package:mpx_1635/models/media_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(query: query),
        ),
      );
    }
  }
  final BookService _bookService = BookService();

  Map<String, List<Book>> featuredSections = {};
  bool loading = true;

  final Map<String, String> sections = {
    "Popular": "popular",
    "Fantasy Picks": "fantasy",
    "Romance Picks": "romance",
    "Mystery Picks": "mystery",
  };

  @override
  void initState() {
    super.initState();
    loadFeaturedSections();
  }

  void loadFeaturedSections() async {
    Map<String, List<Book>> tempSections = {};
    for (var entry in sections.entries) {
      final books = await _bookService.fetchFeaturedBooks(subject: entry.value);
      tempSections[entry.key] = books;
    }

    setState(() {
      featuredSections = tempSections;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home Page',
      onSearch: _handleSearch,
      child: Scaffold(
        body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: featuredSections.entries.map((entry) {
                    final sectionTitle = entry.key;
                    final books = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sectionTitle,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 85, 85, 85)),
                          ),
                          SizedBox(height: 12),
                          BookCarousel(books: books, minCardWidth: 180, maxCardWidth: 200,
                            onAddToPlaylist: (book) {
                              print("Added ${book.title} to playlist");
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ),
          )
      ),
    );
  }
}
