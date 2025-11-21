import 'package:flutter/material.dart';

//maybe add page individually for each media type?
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library"), backgroundColor: Colors.grey),
      body: Container(
        child: Text("This is the library page")
      )
    );
  }
}
