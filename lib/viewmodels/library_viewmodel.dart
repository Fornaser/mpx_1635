import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';
import 'package:mpx_1635/service/google_books_search_service.dart';

class LibraryViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  final Playlist originalPlaylist;

  late String title;
  late List<Map<String, String>> stagedMedia;

  bool loading = true;
  bool editMode = false;

  final List<Book> books = [];

  LibraryViewModel(this.originalPlaylist) {
    title = originalPlaylist.title;
    stagedMedia = List<Map<String, String>>.from(originalPlaylist.media);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    books.clear();

    for (final item in stagedMedia) {
      final id = item['id'];
      final title = item['title'] ?? '';

      if (id == null || id.isEmpty) continue;

      Book? book;
      try {
        book = await _searchService.fetchBookById(id); // fetch by ID
      } catch (_) {}

      if (book == null) {
        book = Book(
          id: id,
          title: title,
          authors: [],
          synopsis: '',
          coverUrl: '',
        );
      }

      books.add(book);
    }

    loading = false;
    notifyListeners();
  }


  void toggleEditMode() {
    editMode = !editMode;
    notifyListeners();
  }

  void deleteBook(Book book) {
    books.removeWhere((b) => b.id == book.id);
    stagedMedia.removeWhere((m) => m['id'] == book.id);
    notifyListeners();
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  Future<Playlist> saveChanges() async {
    final updated = Playlist(
      id: originalPlaylist.id,
      title: title,
      date: originalPlaylist.date,
      mediatype: originalPlaylist.mediatype,
      media: stagedMedia,
    );

    await PlaylistRepository.update(playlist: updated);
    editMode = false;
    notifyListeners();
    return updated;
  }

  Future<void> deletePlaylist() async {
    await PlaylistRepository.delete(playlist: originalPlaylist);
  }
}
