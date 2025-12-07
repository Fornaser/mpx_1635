import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/book_widget.dart';
import 'package:mpx_1635/pages/home_page.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/pages/playlist_page.dart';

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
            orElse: () => results.isNotEmpty ? results[0] : Book(id: id, title: title, authors: [], synopsis: '', coverUrl: ''),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PlaylistPage(),
      ),
    );
  }

  Future<void> _editPlaylist(Playlist playlist, BuildContext context) async {
    
  }

  void _showEditPlaylistDialog(Playlist playlist) async {
    final titleController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newtitle = titleController.text.trim();
              if (newtitle.isEmpty) return;
              final updated = Playlist(
                id: playlist.id,
                date: playlist.date,
                title: newtitle,
                mediatype: playlist.mediatype,
                media: playlist.media
              );
              await PlaylistRepository.update(playlist: updated);
              Navigator.of(context).pop(newtitle);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if(result != null) {
      setState(() {
        _title = result;
      });
    }
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.grey,
        actions: <Widget>[
          PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0, 
                  child: Text('Edit Playlist'),
                  onTap: (){
                    _showEditPlaylistDialog(widget.playlist);
                  },
                ),
                PopupMenuItem<int>(
                  value: 1, 
                  child: Text('Delete Playlist'),
                  onTap: () {
                    _deletePlaylist(widget.playlist, context);
                  },
                ),
              ],
            ),
         ],
      ),
        body: loading
          ? Center(child: Image.asset('RemindDbFull.png', height: 96))
          : books.isEmpty
              ? const Center(child: Text("No books in this playlist."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: books[index],
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => HomePage(),
              ),
            );
          },
      ),
    );
  }
}
