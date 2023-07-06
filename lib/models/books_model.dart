
import 'dart:io';

enum Category { career, education, hobby, cook }

class Book {
  Book({
    required this.title,
    required this.author,
    required this.image,
    required this.datePublished,
    required this.category,
  });

  final String title;
  final String author;
  final File image;
  final DateTime datePublished;
  final Category category;
}