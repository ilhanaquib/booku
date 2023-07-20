import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:booku/models/books_model.dart';
import 'package:booku/databases/database_helper.dart';
import 'edit_book.dart';
import 'package:booku/themes/theme_selection.dart';
import 'package:booku/pages/books_list.dart';
import 'package:booku/databases/firebase_helper.dart';

class Books extends StatefulWidget {
  const Books({Key? key,}) : super(key: key);


  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _dataManagementDropdownOpen = false;
  bool _uploadInProgress = false;
  bool _downloadInProgress = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    displayData();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _isLoggedIn = user != null;
      });
    });
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

  void _startUploadProcess() {
    if (_isLoggedIn) {
      setState(() {
        _uploadInProgress = true;
      });
      synchronizeWithFirebase().then((_) {
        setState(() {
          _uploadInProgress = false;
        });
      });
    } else {
      Navigator.pushNamed(context, '/login').then((value) {
        if (value == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log in to use this feature'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void _startDownloadProcess() {
    if (_isLoggedIn) {
      setState(() {
        _downloadInProgress = true;
      });
      downloadDataToLocalDatabase().then((_) {
        setState(() {
          _downloadInProgress = false;
        });
      });
    } else {
      Navigator.pushNamed(context, '/login').then((value) {
        if (value == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log in to use this feature'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
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
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator or any other UI while waiting for auth state
                  return CircularProgressIndicator();
                }

                final user = snapshot.data;
                final bool isLoggedIn = user != null;

                return ListTile(
                  title: Text(isLoggedIn ? 'Profile' : 'Login / Signup'),
                  onTap: isLoggedIn
                      ? () {
                          // Handle logout here
                          Navigator.pushNamed(context, '/account');
                        }
                      : () {
                          Navigator.pushNamed(context, '/login');
                        },
                );
              },
            ),
            ListTile(
              title: const Text('Themes'),
              onTap: _openThemesSelect,
            ),
            ListTile(
              title: const Text('Data management'),
              trailing: const Icon(Icons.arrow_drop_down),
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
                      if (!_uploadInProgress && !_downloadInProgress) {
                        _startUploadProcess();
                      }
                    },
                    trailing: _uploadInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          )
                        : null,
                  ),
                  ListTile(
                    title: const Text('Download'),
                    onTap: () {
                      if (!_uploadInProgress && !_downloadInProgress) {
                        _startDownloadProcess();
                      }
                    },
                    trailing: _downloadInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          )
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
