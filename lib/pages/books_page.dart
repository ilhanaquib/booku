// this page is to list/show all the books user added to the app

import 'package:booku/pages/books_list.dart';
import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:booku/database_helper.dart';

class Books extends StatefulWidget {
  const Books({
    super.key,
  });

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  // dummy data
  List<Book> _books = [];

  Future<void> displayData() async {
    print('displaAll');
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    // Call the readAllExpense function to retrieve all expenses
    List<Book> allBook = await dbHelper.readAllBook();
    print(allBook);

    // Store the retrieved expenses in the _registeredExpenses list
    _books = allBook;
  }

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: displayData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
