import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:intl/intl.dart';

class BookItem extends StatelessWidget {
  const BookItem({Key? key, required this.book}) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMd();

    return SizedBox(
      height: double.infinity,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20,),
            // book image
            SizedBox(height: 165, child: Image.file(book.image)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Expanded(
                child: Text(
                  book.title.capitalize(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                book.author.capitalize(),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // category
                  Expanded(
                    child: Text(
                      book.category.toString().split('.').last.capitalize(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // date
                  Text(
                    formatter.format(book.datePublished),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This is to capitalize the first letter for the category
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
