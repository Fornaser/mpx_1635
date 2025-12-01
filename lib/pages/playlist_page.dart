import 'package:flutter/material.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'library_page.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistPage> {
  List<Playlist> playlists = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => loading = true);
    final fetched = await PlaylistRepository.getPlaylists();
    setState(() {
      playlists = fetched;
      loading = false;
    });
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    await PlaylistRepository.delete(playlist: playlist);
    _loadPlaylists();
  }

  void _showAddPlaylistDialog() {
    final titleController = TextEditingController();
    String selectedMediaType = 'Book'; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMediaType,
              items: ['Book', 'Movie', 'TV Show']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedMediaType = value;
              },
              decoration: const InputDecoration(labelText: 'Media Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final newPlaylist = Playlist(
                date: DateTime.now(),
                title: title,
                mediatype: selectedMediaType,
                media: [],
              );

              await PlaylistRepository.insert(playlist: newPlaylist);
              Navigator.pop(context);
              _loadPlaylists();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playlists"), backgroundColor: Colors.grey),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : playlists.isEmpty
              ? const Center(child: Text("No playlists found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(playlist.title),
                        trailing: Text(playlist.date.toLocal().toIso8601String().split('T').first),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LibraryPage(playlist: playlist),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaylistDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
