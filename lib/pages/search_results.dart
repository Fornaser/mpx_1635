import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/base_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  void _handleSearch(String query) {
    // Navigate to new search results page with updated query
    if (query.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Search Results',
      onSearch: _handleSearch,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results for: "${widget.query}"',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Placeholder count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text('Result ${index + 1} for "${widget.query}"'),
                      subtitle: const Text('Placeholder search result'),
                      onTap: () {
                        // Handle result tap
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
