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
    await _loadPlaylists();
  }

  void _showAddPlaylistDialog() {
    final titleController = TextEditingController();

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
                mediatype: "Books",
                media: [],
              );

              await PlaylistRepository.insert(playlist: newPlaylist);
              Navigator.pop(context);
              await _loadPlaylists();
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
      backgroundColor: const Color.fromARGB(255, 188, 212, 205),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 112, 171, 153),
        title: const Text("Playlists"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 0) _toggleEditMode();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text("Edit Library")),
            ],
          ),
        ],
      ),
      body: loading
          ? Center(child: Image.asset('RemindDbFull.png', height: 96))
          : playlists.isEmpty
              ? const Center(child: Text("No playlists found."))
              : RefreshIndicator(
                  onRefresh: _loadPlaylists,
                  child: ListView.builder(
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
                                final result = await Navigator.push<Playlist?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LibraryPage(playlist: playlist),
                                  ),
                                );
                                if (result != null && result.id != null) {
                                  await _loadPlaylists();
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
                                onTap: () async {
                                  await _deletePlaylist(playlist);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Deleted "${playlist.title}"')),
                                  );
                                },
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
                ),
      floatingActionButton: _editMode
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _editMode = false);
              },
              icon: const Icon(Icons.close),
              label: const Text("Done Editing"),
            )
          : FloatingActionButton.extended(
              onPressed: _showAddPlaylistDialog,
              icon: const Icon(Icons.add),
              label: const Text("Create New Playlist"),
            ),
    );
  }
}
