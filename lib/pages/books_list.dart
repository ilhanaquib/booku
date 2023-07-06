import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:booku/book_item.dart';
import 'add_book.dart';

class BooksList extends StatefulWidget {
  const BooksList({super.key, required this.books, required this.onAddbook});

  final List<Book> books;
  final void Function(Book) onAddbook;

  @override
  State<BooksList> createState() => _BooksListState();
}

class _BooksListState extends State<BooksList> {
  void _openAddBookOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        useSafeArea: true,
        builder: (ctx) => AddBook(onAddBook: widget.onAddbook));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: widget.books.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: _openAddBookOverlay,
            child: const Card(
              child: Center(
                child: Icon(Icons.add),
              ),
            ),
          );
        } else {
          final book = widget.books[index - 1];
          return BookItem(book: book);
        }
      },
    );
  }
}
