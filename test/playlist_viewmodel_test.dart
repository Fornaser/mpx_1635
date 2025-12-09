import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_1635/viewmodels/playlist_viewmodel.dart';

void main() {
  late PlaylistViewModel vm;

  setUp(() {
    vm = PlaylistViewModel();
  });

  test('initial state', () {
    expect(vm.playlists, []);
    expect(vm.loading, true);
    expect(vm.editMode, false);
  });

  test('toggleEditMode works', () {
    vm.toggleEditMode();
    expect(vm.editMode, true);
    vm.toggleEditMode();
    expect(vm.editMode, false);
  });

  test('addPlaylist adds new playlist', () async {
    await vm.addPlaylist('Test Playlist');
    expect(vm.playlists.length, 1);
    expect(vm.playlists.first.title, 'Test Playlist');
  });

  test('deletePlaylist removes playlist', () async {
    await vm.addPlaylist('Delete Me');
    final playlist = vm.playlists.first;

    await vm.deletePlaylist(playlist);
    expect(vm.playlists.isEmpty, true);
  });
}
