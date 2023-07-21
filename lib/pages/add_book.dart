import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:booku/models/books_model.dart';
import 'package:booku/databases/database_helper.dart';

final formatter = DateFormat.yMd();

class AddBook extends StatefulWidget {
  const AddBook({
    super.key,
    required this.onAddBook,
  });

  final void Function(Book book) onAddBook;

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _pickedImage = '';
  DateTime? _selectedDate;
  Category? category;

  Future<String> getCacheDirectoryPath() async {
    Directory appCacheDirectory = await getApplicationDocumentsDirectory();
    String cachePath = appCacheDirectory.path;
    return cachePath;
  }

  Future<void> pickImage() async {
    try {
      // Show the modal bottom sheet with options
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                    _getImage(ImageSource
                        .camera); // Call _getImage with ImageSource.camera
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                    _getImage(ImageSource
                        .gallery); // Call _getImage with ImageSource.gallery
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      Text(e.toString());
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    final imagePath = image.path;
    setState(() {
      _pickedImage = imagePath;
    });
  }

  void _submitBookData() async {
    //validation check
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _selectedDate == null ||
        _pickedImage == '' ||
        category == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
              'Please make sure a valid title, author, category, date or image is entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // add new expense to list
    final book = Book(
      id: const Uuid().v4(),
      title: _titleController.text,
      author: _authorController.text,
      image: _pickedImage,
      dateAdded: _selectedDate!,
      category: category as Category,
      imageUrl: '',
    );

    try {
      await getDatabasesPath();
      await DatabaseHelper.instance.create(book);

      // Show success dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Book added successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                closeModalBottom();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle database error
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to add book: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Book> fetchImageUrlForBook(Book book) async {
    // Fetch the imageUrl for the book from the appropriate source
    final imageUrl = await fetchImageUrlFromFirebase(book);

    // Create a new book object with the updated imageUrl
    return book.copy(imageUrl: imageUrl ?? '');
  }

  Future<String?> fetchImageUrlFromFirebase(Book book) async {
    try {
      // Assuming you have a 'books' collection in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(book.id)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['imageUrl'] as String?;
      } else {
        return null; // Book document not found
      }
    } catch (e) {
      return null; // Error occurred
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void closeModalBottom() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    File imageFile = File(_pickedImage);
    return Padding(
      padding: const EdgeInsets.only(top: 45, left: 12, right: 12),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            maxLength: 50,
            decoration: const InputDecoration(label: Text('Title')),
          ),
          TextField(
            controller: _authorController,
            maxLength: 50,
            decoration: const InputDecoration(label: Text('Author')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton(
                    hint: const Text('Category'),
                    value: category,
                    items: Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.name.capitalize(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        category = value;
                      });
                    },
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No date Selected'
                        : formatter.format(_selectedDate!),
                  ),
                  IconButton(
                      onPressed: _presentDatePicker,
                      icon: const Icon(Icons.calendar_month))
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: pickImage, child: const Text('Select an image')),
              const SizedBox(width: 13),
              TextButton(
                  onPressed: () {
                    closeModalBottom();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: _submitBookData, child: const Text('Save Book')),
            ],
          ),
          if (_pickedImage == '')
            const Padding(
              padding: EdgeInsets.only(top: 200),
              child: Text('Pick an image to see a preview'),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                  height: 400, width: 350, child: Image.file(imageFile)),
            )
        ],
      ),
    );
  }
}

// this is to capitalize the first letter for the category
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
