import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booku/models/books_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:booku/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

final formatter = DateFormat.yMd();

class EditBook extends StatefulWidget {
  const EditBook({super.key, required this.book});

  final Book book;

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _pickedImage = '';
  DateTime? _selectedDate;
  Category? category;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.book.title;
    _authorController.text = widget.book.author;
    _pickedImage = widget.book.image;
    _selectedDate = widget.book.dateAdded;
    category = widget.book.category;
  }

  Future<String> getCacheDirectoryPath() async {
    Directory appCacheDirectory = await getApplicationDocumentsDirectory();
    String cachePath = appCacheDirectory.path;
    return cachePath;
  }

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imagePath = image.path;
      setState(() {
        _pickedImage = imagePath;
      });
    } catch (e) {
      Text(e.toString());
    }
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
    final updateBook = widget.book.copy(
      title: _titleController.text,
      author: _authorController.text,
      image: _pickedImage,
      dateAdded: _selectedDate!,
      category: category,
    );

    try {
      await getDatabasesPath();
      await DatabaseHelper.instance.update(updateBook);

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
                  onPressed: _submitBookData, child: const Text('Save Edit')),
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
