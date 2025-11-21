import 'package:flutter/material.dart';

//maybe add page individually for each media type?
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie"), backgroundColor: Colors.grey),
      body: Container(
        child: Text("This is the media page")
      )
    );
  }
}
