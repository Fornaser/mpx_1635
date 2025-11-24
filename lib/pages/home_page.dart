import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/base_page.dart';
import 'package:mpx_1635/pages/search_results.dart';

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

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home Page',
      onSearch: _handleSearch,
      child: const Center(
        child: Text(
          'This is the home page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
