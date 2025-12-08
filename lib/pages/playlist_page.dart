import 'package:flutter/material.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/pages/library_page.dart';
import 'package:mpx_1635/scr/sidebar/widgets/nav_bar/navigation_drawer.dart';
import 'package:mpx_1635/viewmodels/playlist_viewmodel.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaylistViewModel(),
      child: const _PlaylistPageBody(),
    );
  }
}

class _PlaylistPageBody extends StatelessWidget {
  const _PlaylistPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaylistViewModel>();

    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      backgroundColor: const Color.fromARGB(255, 188, 212, 205),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 112, 171, 153),
        title: const Text("Playlists"),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 0) vm.toggleEditMode();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text("Edit Library")),
            ],
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.playlists.isEmpty
              ? const Center(child: Text("No playlists found."))
              : RefreshIndicator(
                  onRefresh: vm.loadPlaylists,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = vm.playlists[index];
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
                                  vm.loadPlaylists();
                                }
                              },
                            ),
                          ),
                          if(vm.editMode)
                            Positioned(
                              right: 10,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  await vm.deletePlaylist(playlist);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Deleted "${playlist.title}"')),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (vm.editMode) {
            vm.toggleEditMode();
          } else {
            final controller = TextEditingController();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Add New Playlist"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () {
                      vm.addPlaylist(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
            );
          }
        },
        icon: Icon(vm.editMode ? Icons.close : Icons.add),
        label: Text(vm.editMode ? "Done Editing" : "Create New Playlist"),
      ),
    );
  }
}
