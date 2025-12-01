//import 'package:flutter/foundation.dart';

enum MediaType { book }

MediaType _typeFromString(String t) {
  switch (t.toLowerCase()) {
    case 'books':
    case 'book': return MediaType.book;
    // case 'movies':
    // case 'movie': return MediaType.movie;
    // case 'tvs':
    // case 'tv': return MediaType.tv;
    default: return MediaType.book;
  }
}

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String synopsis;
  final String coverUrl;

  Book(
    {
      required this.id, 
      required this.title, 
      required this.authors, 
      required this.synopsis,
      required this.coverUrl, 
    }
  );

  factory Book.fromSearchJson(Map<String, dynamic> json) {
    // cover image
    final coverId = json['cover_i'];
    final coverUrl = coverId != null
        ? "https://covers.openlibrary.org/b/id/$coverId-L.jpg"
        : "";

    final id = (json['edition_key'] != null && json['edition_key'].isNotEmpty)
        ? json['edition_key'][0]
        : "";

    return Book(
      id: id,
      title: json['title'] ?? '',
      authors: (json['author_name'] != null && json['author_name'].isNotEmpty)
          ? json['author_name'][0]
          : "Unknown",
      synopsis: "", 
      coverUrl: coverUrl,
    );
  }

  factory Book.fromDetailsJson(Map<String, dynamic> json, String id) {
    final cover = json["covers"] != null && json["covers"].isNotEmpty
        ? "https://covers.openlibrary.org/b/id/${json["covers"][0]}-L.jpg"
        : "";

    final description = json["description"];
    String synopsis = "";
    if (description is String) {
      synopsis = description;
    } else if (description is Map) {
      synopsis = description["value"] ?? "";
    }

    return Book(
      id: id,
      title: json['title'] ?? '',
      authors: [], 
      synopsis: synopsis,
      coverUrl: cover,
    );
  }
}

class Movie {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String description;
  final String organizer;
  final List<Map<String,String>> attendees;
  final DateTime createdAt;

  Movie(
    {
      required this.id, 
      required this.title, 
      required this.startTime, 
      required this.endTime,
      required this.location,
      required this.description, 
      required this.organizer,
      required this.attendees, 
      required this.createdAt
    }
  );

  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
    id: j['id'] as String,
    title: j['title'] as String,
    startTime: DateTime.parse(j['start_time'] as String),
    endTime: DateTime.parse(j['end_time'] as String),
    location: j['location'] as String,
    description: j['description'] as String,
    organizer: j['organizer'] as String,
    attendees: (j['attendees'] as List<dynamic>? ?? []).map((a) => Map<String,String>.from(a)).toList(),
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}

class Tv {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String assignedTo;
  final DateTime dueDate;
  final String description;
  final double estimateHours;
  final DateTime createdAt;
  final DateTime? completedAt;

  Tv(
    {
      required this.id, 
      required this.title, 
      required this.status, 
      required this.priority,
      required this.assignedTo, 
      required this.dueDate, 
      required this.description,
      required this.estimateHours, 
      required this.createdAt, this.completedAt
    }
  );
  
  factory Tv.fromJson(Map<String, dynamic> j) => Tv(
    id: j['id'] as String,
    title: j['title'] as String,
    status: j['status'] as String,
    priority: j['priority'] as String,
    assignedTo: j['assigned_to'] as String,
    dueDate: DateTime.parse(j['due_date'] as String),
    description: j['description'] as String,
    estimateHours: (j['estimate_hours'] as num).toDouble(),
    createdAt: DateTime.parse(j['created_at'] as String),
    completedAt: j['completed_at'] == null ? null : DateTime.parse(j['completed_at'] as String),
  );
}

class Media {
  final MediaType type;
  final dynamic content; 
  final DateTime createdAt;

  Media({
    required this.type,
    required this.content,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> j) {
    final type = _typeFromString(j['type'] ?? '');
    switch (type) {
      case MediaType.book:
        return Media(
          type: type,
          content: Book.fromSearchJson(j['content']),
          createdAt: DateTime.parse(j['content']['created_at']),
        );
      // case Media.movie:
      //   return Message(
      //     type: type,
      //     content: Movie.fromSearchJson(j['content']),
      //     createdAt: DateTime.parse(j['content']['created_at']),
      //   );
      // case Media.tv:
      //   return Message(
      //     type: type,
      //     content: Tv.fromSearchJson(j['content']),
      //     createdAt: DateTime.parse(j['content']['created_at']),
      //   );
    }
  }
}
