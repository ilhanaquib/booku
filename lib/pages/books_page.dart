import 'package:booku/data_selection.dart';
import 'package:booku/pages/books_list.dart';
import 'package:flutter/material.dart';
import 'package:booku/models/books_model.dart';
import 'package:booku/databases/database_helper.dart';
import 'edit_book.dart';
import 'package:booku/themes/theme_selection.dart';

class Books extends StatefulWidget {
  const Books({
    Key? key,
  }) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _dataManagementDropdownOpen = false;
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
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(book.id);
    setState(() {
      _books.remove(book);
    });
  }

  void _editBook(Book book) async {
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
        builder: (context) => EditBook(
              book: book,
            ));
  }

  void _openThemesSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemeSelectionScreen(),
      ),
    );
  }

  void _openDataSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataSelection(),
      ),
    );
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Booku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: mainContent),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('Themes'),
              onTap: _openThemesSelect,
            ),
            ListTile(
              title: const Text('Data management'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                // Handle the tap to open/close the dropdown
                setState(() {
                  // Toggle the dropdown state
                  _dataManagementDropdownOpen = !_dataManagementDropdownOpen;
                });
              },
            ),
            if (_dataManagementDropdownOpen) // Show the dropdown if it's open
              Column(
                children: [
                  ListTile(
                    title: const Text('Upload'),
                    onTap: () {
                      // Handle button 1 tap
                    },
                  ),
                  ListTile(
                    title: const Text('Download'),
                    onTap: () {
                      // Handle button 2 tap
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
