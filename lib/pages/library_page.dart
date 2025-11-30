import 'package:flutter/material.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/pages/home_page.dart';

class LibraryPage extends StatelessWidget {
  final Playlist playlist;

  const LibraryPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist.title), backgroundColor: Colors.grey),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: playlist.media.isEmpty
            ? const Center(child: Text("No media in this playlist."))
            : ListView.separated(
                itemCount: playlist.media.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = playlist.media[index];
                  return ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(item),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      ),
    );
  }
}
