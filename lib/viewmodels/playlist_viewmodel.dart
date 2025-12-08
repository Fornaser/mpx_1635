import 'package:flutter/material.dart';
import 'package:mpx_1635/models/playlist_model.dart';
import 'package:mpx_1635/models/playlist_repository.dart';

class PlaylistViewModel extends ChangeNotifier {
  bool loading = true;
  bool editMode = false;
  List<Playlist> playlists = [];

  PlaylistViewModel() {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    loading = true;
    notifyListeners();

    playlists = await PlaylistRepository.getPlaylists();

    loading = false;
    notifyListeners();
  }

  void toggleEditMode() {
    editMode = !editMode;
    notifyListeners();
  }

  Future<void> addPlaylist(String title, {String mediaType = "Books"}) async {
    if (title.trim().isEmpty) return;

    final newPlaylist = Playlist(
      date: DateTime.now(),
      title: title,
      mediatype: mediaType,
      media: [],
    );

    await PlaylistRepository.insert(playlist: newPlaylist);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await PlaylistRepository.delete(playlist: playlist);
    playlists.removeWhere((p) => p.id == playlist.id);
    notifyListeners();
  }
}
