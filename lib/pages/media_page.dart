import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';
import 'package:mpx_1635/widgets/remind_button.dart';
import 'package:flutter_html/flutter_html.dart';

class MediaPage extends StatefulWidget {
  final Book book;

  const MediaPage({super.key, required this.book});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> with SingleTickerProviderStateMixin {
  final SearchService _searchService = SearchService();
  bool loading = true;
  late Book fullBook;
  late final AnimationController _animController;


  @override
  void initState() {
    super.initState();
    fullBook = widget.book;
    _loadBookDetails();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );


  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadBookDetails() async {
    try {
      final book = await _searchService.fetchBookById(fullBook.id);
      if (!mounted) return;

      setState(() {
        if (book != null) fullBook = book;
        loading = false;
      });
    } catch (e) {
      print("Error loading book: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void _showAddToPlaylistDialog() async {
    final playlists = await PlaylistRepository.getPlaylists();

    final scaffoldContext = context; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: playlists.isEmpty
            ? const Text('No playlists available.')
            : SizedBox(
                width: 500,
                height: 300,
                child: ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      title: Text(playlist.title),
                      onTap: () async {
                        playlist.media.add({
                          'id': fullBook.id,
                          'title': fullBook.title,
                          'authors': fullBook.authors.join(", "),
                        });

                        await PlaylistRepository.update(playlist: playlist);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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
      backgroundColor: const Color.fromARGB(255, 188, 212, 205),
      appBar: AppBar(title: Text("RemindDB"), backgroundColor: const Color.fromARGB(255, 112, 171, 153),),
      body: loading
      ? Center(child: Image.asset('RemindDbFull.png', height: 96))
      : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                              height: 300,
                              width: double.infinity,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: RemindButton(book: fullBook),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullBook.title,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(fullBook.authors.join(", "),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    Html(data: fullBook.synopsis),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
