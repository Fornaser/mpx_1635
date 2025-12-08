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
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    fullBook = widget.book;
    _loadBookDetails();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    ]).animate(_animController);

    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_animController);
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
                        // Add Google Books info as a map
                        playlist.media.add({
                          'id': fullBook.id,
                          'title': fullBook.title,
                          'authors': fullBook.authors.join(", "),
                        });

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

  void _handleRemindTap() async {
    // Prevent overlapping animations
    if (_animController.isAnimating) return;
    try {
      await _animController.forward(from: 0.0);
    } catch (_) {
      // Ignore animation errors
    }
    if (!mounted) return;

    await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        String selected = 'Once a day';
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-left X button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Remind me in:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButtonFormField<String>(
                      value: selected,
                      onChanged: (v) => setState(() => selected = v ?? selected),
                      items: const [
                        DropdownMenuItem(value: 'Once a day', child: Text('Once a day')),
                        DropdownMenuItem(value: 'Once a week', child: Text('Once a week')),
                        DropdownMenuItem(value: 'Once a month', child: Text('Once a month')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Close and return selection (functionality not implemented)
                          Navigator.of(context).pop(selected);
                        },
                        child: const Text('Confirm'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("RemindDB"), backgroundColor: Colors.grey),
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
                    // Use the extracted RemindButton widget
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
