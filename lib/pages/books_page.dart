// this page is to list/show all the books user added to the app

import 'package:booku/pages/books_list.dart';
import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';

class Books extends StatefulWidget {
  const Books({
    super.key,
  });

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  // dummy data
  final List<Book> _books = [];

    void _addBook(Book book) {
    setState(() {
      _books.add(book);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = BooksList(
        onAddbook: _addBook,
        books: _books,
      );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Booku'),
        ),
        body: Column(
          children: [Expanded(child: mainContent)],
        ));
  }
}
