import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_widget.dart';
import 'package:mpx_1635/pages/home_page.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/pages/playlist_page.dart';
import 'package:mpx_1635/pages/media_page.dart';

class LibraryPage extends StatefulWidget {
  final Playlist playlist;

  const LibraryPage({super.key, required this.playlist});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final SearchService _searchService = SearchService();
  late String _title;
  bool loading = true;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _title = widget.playlist.title;
  }

  Future<void> _loadBooks() async {
    List<Book> loadedBooks = [];

    for (var item in widget.playlist.media) {
      try {
        final id = item['id'];
        final title = item['title'] ?? '';

        if (id != null && id.isNotEmpty) {
          final results = await _searchService.searchBooks(title);
          final book = results.firstWhere(
            (b) => b.id == id,
            orElse: () =>
                results.isNotEmpty ? results[0] : Book(id: id, title: title, authors: [], synopsis: '', coverUrl: ''),
          );
          loadedBooks.add(book);
        }
      } catch (e) {
        print("Error loading book ${item['title']}: $e");
      }
    }

    if (!mounted) return;
    setState(() {
      books = loadedBooks;
      loading = false;
    });
  }

  Future<void> _deletePlaylist(Playlist playlist, BuildContext context) async {
    await PlaylistRepository.delete(playlist: playlist);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaylistPage()));
  }

  Future<void> _deleteBookFromPlaylist(Book book) async {
    setState(() {
      books.removeWhere((b) => b.id == book.id);
    });

    widget.playlist.media.removeWhere((item) => item['id'] == book.id);
    await PlaylistRepository.update(playlist: widget.playlist);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${book.title} removed from playlist")),
    );
  }

  void _showEditPlaylistDialog(Playlist playlist) async {
    final titleController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final newTitle = titleController.text.trim();
              if (newTitle.isEmpty) return;

              final updatedPlaylist = Playlist(
                id: playlist.id,
                date: playlist.date,
                title: newTitle,
                mediatype: playlist.mediatype,
                media: playlist.media,
              );

              await PlaylistRepository.update(playlist: updatedPlaylist);
              Navigator.pop(context, newTitle);
            },
          )
        ],
      ),
    );
    if (result != null) {
      setState(() => _title = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        bottomOpacity: 10,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 0,
                  child: const Text("Edit Playlist"),
                  onTap: () => _showEditPlaylistDialog(widget.playlist)),
              PopupMenuItem(
                  value: 1,
                  child: const Text("Delete Playlist"),
                  onTap: () => _deletePlaylist(widget.playlist, context)),
            ],
          ),
        ],
      ),
        body: loading
          ? Center(child: Image.asset('RemindDbFull.png', height: 96))
          : books.isEmpty
              ? const Center(child: Text("No books in this playlist."))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    int columns = (width / 180).floor(); 
                    columns = columns.clamp(2, 8); 
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.45, 
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          MediaPage(book: books[index]))),
                              child: BookCard(book: books[index]),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    _deleteBookFromPlaylist(books[index]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        ),
      ),
    );
  }
}
