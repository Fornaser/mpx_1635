
import 'dart:convert';

class Playlist {
  int? id;
  final DateTime date;
  String title;
  String mediatype;
  List<String> media;

  Playlist({
    this.id,
    required this.date,
    required this.title,
    required this.mediatype, 
    required this.media
  });

  Map<String, Object?> toMap() {
    return {'date': date.toString(), 'title': title, 'mediatype': mediatype, 'media': jsonEncode(media)};
  }

  @override
  String toString() {
    return 'Diary{id: $id, date: $date, title: $title, mediatype: $mediatype, media: $media}';
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      date: map['date'],
      title: map['title'],
      mediatype: map['mediatype'],
      media: List<String>.from(jsonDecode(map['media'])),
    );
  }
}