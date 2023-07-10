import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class BookItem extends StatelessWidget {
  const BookItem(
      {Key? key,
      required this.book,
      required this.removeBook,
      required this.editBook})
      : super(key: key);

  final Book book;
  final void Function(Book) removeBook;
  final void Function(Book) editBook;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMd();
    File imageFile = File(book.image);

    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 250,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      book.title.capitalize(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      softWrap: true,
                      textAlign: TextAlign.center,
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
                            book.category
                                .toString()
                                .split('.')
                                .last
                                .capitalize(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // date
                        Text(
                          formatter.format(book.dateAdded),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 320,
                left: 150,
                child: PopupMenuButton(
                  icon: const Icon(
                    Icons.more_horiz_outlined,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      editBook(book);
                    } else if (value == 'delete') {
                      removeBook(book);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete' , style: TextStyle(color: Colors.red),),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
