
import 'dart:convert';

class Playlist {
  int? id;
  final DateTime date;
  String title;
  String mediatype;
  List<Map<String, String>> media;

  Playlist({
    this.id,
    required this.date,
    required this.title,
    required this.mediatype,
    required this.media,
  });

  Map<String, Object?> toMap() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'mediatype': mediatype,
      'media': jsonEncode(media),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      mediatype: map['mediatype'],
      media: List<Map<String, String>>.from(jsonDecode(map['media'])),
    );
  }
}
