import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/base_page.dart';
import 'package:mpx_1635/pages/search_results_page.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_carousel.dart';
import 'package:mpx_1635/models/media_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SearchService _searchService = SearchService();
  bool loading = true;
  Map<String, List<Book>> featuredSections = {};

  final Map<String, String> sections = {
  "Best Fiction Picks": "subject:Fiction",
  "Fantasy Picks": "subject:Fantasy",
  "Romance Picks": "subject:Romance",
  "Mystery Picks": "subject:Mystery",
};


  @override
  void initState() {
    super.initState();
    _loadFeaturedSections();
  }

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

  Future<void> _loadFeaturedSections() async {
    Map<String, List<Book>> tempSections = {};

    for (var entry in sections.entries) {
      try {
        final books = await _searchService.searchBooks(entry.value);
        tempSections[entry.key] = books;
      } catch (e) {
        print("Error loading ${entry.key}: $e");
        tempSections[entry.key] = [];
      }
    }

    if (!mounted) return;
    setState(() {
      featuredSections = tempSections;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home Page',
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Image.asset(
          'RemindDbFull.png',
          height: 56,
          fit: BoxFit.contain,
          semanticLabel: 'RemindDb logo',
        ),
      ),
      appBarColor: const Color.fromARGB(255, 112, 171, 153),
            backgroundColor: const Color.fromARGB(255, 188, 212, 205),

        onSearch: _handleSearch,
        child: loading
          ? Center(child: Image.asset('RemindDbFull.png', height: 96))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: featuredSections.entries.map((entry) {
                  final sectionTitle = entry.key;
                  final books = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sectionTitle,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 85, 85, 85)),
                        ),
                        const SizedBox(height: 12),
                        BookCarousel(
                          books: books,
                          minCardWidth: 180,
                          maxCardWidth: 200,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
