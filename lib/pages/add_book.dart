import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booku/models/books_model.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final formatter = DateFormat.yMd();

class AddBook extends StatefulWidget {
  const AddBook({super.key, required this.onAddBook});

  final void Function(Book book) onAddBook;

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  File? _pickedImage;
  DateTime? _selectedDate;
  Category? category;

  Future<String> getCacheDirectoryPath() async {
  Directory appCacheDirectory = await getApplicationDocumentsDirectory();
  String cachePath = appCacheDirectory.path;
  return cachePath;
}



  Future<void> pickImage() async {
    String cacheDirectory = await getCacheDirectoryPath();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        _pickedImage = imageTemp;
        print('this is the path : $_pickedImage');
        print('this is the cache director $cacheDirectory');
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _submitBookData() {
    //validation check
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _selectedDate == null ||
        _pickedImage == null ||
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
    widget.onAddBook(
      Book(
          title: _titleController.text,
          author: _authorController.text,
          image: _pickedImage!,
          datePublished: _selectedDate!,
          category: category as Category),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book added succesfully'),
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
              Spacer(),
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
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: pickImage, child: const Text('Select an image')),
              const SizedBox(width: 31),
              TextButton(
                  onPressed: () {
                    closeModalBottom();
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: _submitBookData, child: Text('Save Book')),
            ],
          ),
          if (_pickedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              height: 400,
              width:  350,
              child: Image.file(_pickedImage!)),
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
