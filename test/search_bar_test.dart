/* This is the origonal test for the search bar widget. What it tests for
is main functionality of the search bar including searching and displaying results.
Currently, in this test it only displays placeholder serch results.
 */

import 'package:flutter/material.dart';

class GlobalSearchBar extends StatefulWidget {
  final Function(String) onSearch; // Changed to stateful, will only work on enter click

  const GlobalSearchBar({super.key, required this.onSearch});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    widget.onSearch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton( //can change later so also works with click on icon
            tooltip: 'Search',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _submit(_controller.text),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: _submit,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}