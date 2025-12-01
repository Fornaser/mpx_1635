import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onAdd;

  const BookCard({super.key, required this.book, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Provide a vertical layout that stretches to available height inside a Grid cell
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover image area
              Expanded(
                flex: 7,
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              // Title & author
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.book, size: 42, color: Colors.grey)),
      );
}
