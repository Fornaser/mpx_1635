import 'package:flutter/material.dart';
import '../models/media_model.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final coverHeight = constraints.maxHeight * 0.70; 
        final coverWidth = constraints.maxWidth;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              SizedBox(
                width: coverWidth,
                height: coverHeight,
                child: _buildCover(),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Authors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  book.authors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCover() {
    final url = book.coverUrl.startsWith("http")
        ? book.coverUrl.replaceFirst("http://", "https://")
        : book.coverUrl;

    if (url.isEmpty) {
      return _fallbackCover();
    }

    return FadeInImage.assetNetwork(
      placeholder: 'assets/book.jpg',
      image: url,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) => _fallbackCover(),
      placeholderErrorBuilder: (context, error, stackTrace) => _fallbackCover(),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.book, size: 40),
      ),
    );
  }
}
