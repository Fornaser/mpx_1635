import 'package:flutter/material.dart';
import 'package:mpx_1635/models/media_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onAdd;

  const BookCard({super.key, required this.book, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 200, 
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 2/3,
                  child: book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          width: 120,
                        )
                      : Container(
                          color: Colors.grey[300],
                          height: 180,
                          child: Icon(Icons.book, size: 50),
                        ),
                )
              ),
              SizedBox(height: 8),
              Text(
                book.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                book.authors.join(', '),
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
