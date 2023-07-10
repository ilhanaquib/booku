// this page is to list/show all the books user added to the app

import 'package:booku/pages/books_list.dart';
import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:booku/database_helper.dart';
import 'edit_book.dart';

class Books extends StatefulWidget {
  const Books({
    Key? key,
  }) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  @override
  void initState() {
    super.initState();
    displayData();
  }

  // dummy data
  List<Book> _books = [];

  Future<void> displayData() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    List<Book> allBooks = await dbHelper.readAllBook();

    setState(() {
      _books = allBooks;
    });
  }

  void _addBook(Book book) {
    setState(() {
      _books.add(book);
    });
  }

  void _removeBook(Book book) async {
    print('_removeBook is being called');
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(book.id);
    setState(() {
      _books.remove(book);
    });
  }

    void _editBook(Book book) async {
    print('__editBook is being called');
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.update(book);
    setState(() {
      _openEditBookOverlay(book);
    });
  }


  void _openEditBookOverlay(Book book) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        useSafeArea: true,
        builder: (context) =>  EditBook(book: book,));
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = BooksList(
      onAddbook: _addBook,
      onRefresh: displayData,
      onRemove: _removeBook,
      onEdit: _editBook,
      books: _books,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booku'),
      ),
      body: Column(
        children: [Expanded(child: mainContent)],
      ),
    );
  }
}
