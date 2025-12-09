import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/pages/home_page.dart';
import 'package:mpx_1635/pages/media_page.dart';
import 'package:mpx_1635/widgets/book_widget.dart';
import 'package:mpx_1635/viewmodels/library_viewmodel.dart';

class LibraryPage extends StatelessWidget {
  final Playlist playlist;

  const LibraryPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryViewModel(playlist),
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();

    final size = MediaQuery.of(context).size;
    final columns = (size.width ~/ 180).clamp(2, 8);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 212, 205),
      appBar: AppBar(
        title: Text(vm.title),
        backgroundColor: const Color.fromARGB(255, 112, 171, 153),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) async {
              if (value == 0) {
                final controller = TextEditingController(text: vm.title);
                final newTitle = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Edit Playlist Title"),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                );
                if(newTitle != null && newTitle.isNotEmpty) {
                  vm.updateTitle(newTitle);
                }
              }

              if(value == 1) {
                await vm.deletePlaylist();
                if (context.mounted) Navigator.pop(context, null);
              }

              if(value == 2) vm.toggleEditMode();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text("Edit Title")),
              PopupMenuItem(value: 1, child: Text("Delete Playlist")),
              PopupMenuItem(value: 2, child: Text("Edit Playlist")),
            ],
          ),
        ],
      ),

      floatingActionButton: vm.editMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                final updated = await vm.saveChanges();
                if (context.mounted) Navigator.pop(context, updated);
              },
              icon: const Icon(Icons.close),
              label: const Text("Done Editing"),
            )
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage())),
              icon: const Icon(Icons.add),
              label: const Text("Add Book"),
            ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.books.isEmpty
              ? const Center(child: Text("No books in this playlist."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: vm.books.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.48,
                    ),
                    itemBuilder: (_, i) {
                      final book = vm.books[i];
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MediaPage(book: book),
                              ),
                            ),
                            child: BookCard(book: book),
                          ),
                          if (vm.editMode)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => vm.deleteBook(book),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
