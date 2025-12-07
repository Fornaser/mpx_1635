import 'package:flutter/material.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'library_page.dart';
import 'package:mpx_1635/scr/sidebar/widgets/nav_bar/navigation_drawer.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistPage> {
  List<Playlist> playlists = [];
  bool loading = true;
  bool _editMode = false; 

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
    String selectedMediaType = 'Books';

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
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  void _toggleEditMode() {
    setState(() => _editMode = !_editMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        title: const Text("Playlists"),
        actions: [
           PopupMenuButton<int>(
           onSelected: (value) {
            if(value == 0) _toggleEditMode();
           },
           itemBuilder: (_) => [
            const PopupMenuItem(value: 0, child: Text("Edit Library"),)
           ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : playlists.isEmpty
              ? const Center(child: Text("No playlists found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(playlist.title),
                            subtitle: Text(
                              '${playlist.mediatype} • ${playlist.date.toLocal().toIso8601String().split('T').first}',
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LibraryPage(playlist: playlist),
                                ),
                              );
                              if (result != null && result is Playlist) {
                                setState(() {
                                  final idx = playlists.indexWhere((p) => p.id == result.id);
                                  if (idx != -1) playlists[idx] = result;
                                });
                              }
                            },
                          ),
                        ),
                        if (_editMode)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => _deletePlaylist(playlist),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
      floatingActionButton: _editMode
        ? FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _editMode = false; 
              });
            },
            icon: const Icon(Icons.close),
            label: const Text("Done Editing"),
          )
        : FloatingActionButton.extended(
            onPressed: _showAddPlaylistDialog,
            icon: const Icon(Icons.add),
            label: const Text("Create New Playlist"),
          )
    );
  }
}
