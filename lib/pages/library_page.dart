import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_widget.dart';
import 'package:mpx_1635/pages/home_page.dart';
import 'package:mpx_1635/pages/media_page.dart';
import 'package:mpx_1635/models/playlist_repository.dart';

class LibraryPage extends StatefulWidget {
  final Playlist playlist;

  const LibraryPage({super.key, required this.playlist});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final SearchService _searchService = SearchService();

  late String _title;
  bool _loading = true;
  bool _editMode = false;
  List<Book> _books = [];
  List<Map<String, String>> _stagedMedia = [];

  @override
  void initState() {
    super.initState();
    _title = widget.playlist.title;
    _stagedMedia = List<Map<String, String>>.from(widget.playlist.media);
    _loadBooks();

  }

  
  Future<void> _loadBooks() async {
    List<Book> resultBooks = [];
    for (var item in _stagedMedia) { 
      try {
        final id = item["id"];
        final title = item["title"] ?? "";
        if (id != null && id.isNotEmpty) {
          final results = await _searchService.searchBooks(title);
          final match = results.firstWhere(
            (b) => b.id == id,
            orElse: () => results.isNotEmpty
                ? results.first
                : Book(id: id, title: title, authors: [], synopsis: "", coverUrl: ""),
          );
          resultBooks.add(match);
        }
      } catch (e) {
        print("Error loading book ${item['title']} → $e");
      }
    }

    if (!mounted) return;
    setState(() {
      _books = resultBooks;
      _loading = false;
    });
  }


  void _deleteBook(Book book) {
    setState(() {
      _books.removeWhere((b) => b.id == book.id);
      _stagedMedia.removeWhere((item) => item['id'] == book.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${book.title} removed from playlist")),
    );
  }


  Future<void> _saveChanges() async {
    final updatedPlaylist = Playlist(
      id: widget.playlist.id,
      title: _title,
      date: widget.playlist.date,
      mediatype: widget.playlist.mediatype,
      media: _stagedMedia,
    );

    await PlaylistRepository.update(playlist: updatedPlaylist);

    setState(() => _editMode = false);

    Navigator.pop(context, updatedPlaylist); 
  }

  Future<void> _deletePlaylist() async {
    await PlaylistRepository.delete(playlist: widget.playlist);
    if (!mounted) return;
    Navigator.pop(context, null); 
  }


  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Playlist Title"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Title"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      final updatedPlaylist = Playlist(
        id: widget.playlist.id,
        date: widget.playlist.date,
        title: newTitle,
        mediatype: widget.playlist.mediatype,
        media: widget.playlist.media,
      );

      await PlaylistRepository.update(playlist: updatedPlaylist);

      setState(() => _title = newTitle);
      // Return updated playlist to PlaylistPage
      Navigator.pop(context, updatedPlaylist);
    }
  }

  void _toggleEditMode() {
    setState(() => _editMode = !_editMode);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    int columns = size.width ~/ 180; 
    columns = columns.clamp(2, 8);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 0) _editTitle();
              if (value == 1) _deletePlaylist();
              if (value == 2) _toggleEditMode();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 0, child: Text("Edit Title")),
              const PopupMenuItem(value: 1, child: Text("Delete Playlist")),
              const PopupMenuItem(value: 2, child: Text("Edit Playlist")),
            ],
          ),
        ],
      ),
      floatingActionButton: _editMode
          ? FloatingActionButton.extended(
              onPressed: _saveChanges,
              icon: const Icon(Icons.close),
              label: const Text("Done Editing"),
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Add Book"),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(child: Text("No books in this playlist."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.48,
                    ),
                    itemCount: _books.length,
                    itemBuilder: (context, i) {
                      final book = _books[i];
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MediaPage(book: book)),
                            ),
                            child: BookCard(book: book),
                          ),
                          if (_editMode)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _deleteBook(book),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
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
