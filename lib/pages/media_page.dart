import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/service/book_service.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/models/playlist_model.dart';

class MediaPage extends StatefulWidget {
  final Book book;

  const MediaPage({super.key, required this.book});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final BookService _bookService = BookService();
  bool loading = true;
  late Book fullBook;

  @override
  void initState() {
    super.initState();
    fullBook = widget.book;
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final details = await _bookService.fetchBookDetails(widget.book.id);
      if (!mounted) return; 
      setState(() {
        fullBook = Book(
          id: details.id,
          title: details.title,
          authors: details.authors.isNotEmpty ? details.authors : widget.book.authors,
          synopsis: details.synopsis,
          coverUrl: details.coverUrl,
        );
        loading = false;
      });
    } catch (e) {
      print("Failed to load book: $e");

      if (!mounted) return; 
      setState(() {
        fullBook = widget.book;
        loading = false;
      });
    }
  }

  void _showAddToPlaylistDialog() async {
    List<Playlist> playlists = await PlaylistRepository.getPlaylists();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: playlists.isEmpty
            ? const Text('No playlists available.')
            : SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      title: Text(playlist.title),
                      onTap: () async {
                        playlist.media.add(fullBook.title); 
                        await PlaylistRepository.update(playlist: playlist);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to ${playlist.title}')),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fullBook.title), backgroundColor: Colors.grey),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Flex(
              direction: constraints.maxWidth > 600 ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: fullBook.coverUrl.isNotEmpty
                            ? Image.network(
                                fullBook.coverUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Container(
                                color: Colors.grey[300],
                                height: 180,
                                child: const Icon(Icons.book, size: 50),
                              ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showAddToPlaylistDialog,
                          child: const Text("Add to List"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Remind Me"),
                        ),
                      ),
                    ],
                  ),
                ),
                if (constraints.maxWidth > 600) const SizedBox(width: 16) else const SizedBox(height: 16),
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullBook.title,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fullBook.authors.isNotEmpty
                            ? fullBook.authors.join(", ")
                            : (loading ? "Loading authors..." : "Unknown author"),
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullBook.synopsis.isNotEmpty
                            ? fullBook.synopsis
                            : (loading ? "Loading description..." : "No description available."),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
