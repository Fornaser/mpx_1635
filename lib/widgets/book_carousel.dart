import 'package:flutter/material.dart';
import '../models/media_model.dart';
import 'book_widget.dart';
import 'package:mpx_1635/pages/media_page.dart';
class BookCarousel extends StatefulWidget {
  final List<Book> books;
  final void Function(Book) onAddToPlaylist;
  final double minCardWidth;
  final double maxCardWidth;
  final double edgePadding; 

  const BookCarousel({
    super.key,
    required this.books,
    required this.onAddToPlaylist,
    this.minCardWidth = 140,
    this.maxCardWidth = 200,
    this.edgePadding = 16,
  });

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  late PageController _pageController;
  int currentIndex = 0;
  late double cardWidth;
  late double viewportFraction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    cardWidth = (screenWidth / 3).clamp(widget.minCardWidth, widget.maxCardWidth);
    viewportFraction = cardWidth / screenWidth;
    _pageController = PageController(viewportFraction: viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = cardWidth * 1.8;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.edgePadding),
          child: SizedBox(
            height: height,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false, 
              itemCount: widget.books.length,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) {
                final book = widget.books[index];
                final bool active = index == currentIndex;

                return AnimatedScale(
                  duration: Duration(milliseconds: 300),
                  scale: active ? 1 : 0.95,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MediaPage(book: book),
                            ),
                          );
                        },
                        child: BookCard(
                          book: book,
                          onAdd: () => widget.onAddToPlaylist(book),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
