

enum Category { career, education, hobby, cook }

// this section is for database

// this is to name the table. table is called expense
const String tableBook = 'books';

class BookFields {
  static final List<String> values = [id, title, author, image, date, category];

  // this variable is to name the columns. it does not store data
  static const String id = '_id';
  static const String title = '_title';
  static const String author = '_author';
  static const String image = '_image';
  static const String date = '_date';
  static const String category = '_category';
}

//------------------------------

class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.image,
    required this.dateAdded,
    required this.category,
  });

  final String id;
  final String title;
  final String author;
  final String image;
  final DateTime dateAdded;
  final Category category;

  Map<String, Object?> toJson() => {
        BookFields.id: id,
        BookFields.title: title,
        BookFields.image: image,
        BookFields.author: author,
        BookFields.date: dateAdded.toIso8601String(),
        BookFields.category: categoryToString(category),
      };

  String categoryToString(Category category) {
    return category.toString().split('.').last;
  }

  Book copy({
    String? id,
    String? title,
    String? author,
    String? image,
    DateTime? dateAdded,
    Category? category,
  }) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        image: image ?? this.image,
        dateAdded: dateAdded ?? this.dateAdded,
        category: category ?? this.category,
      );

  static Book fromJson(Map<String, Object?> json) => Book(
        id: json[BookFields.id] as String,
        title: json[BookFields.title] as String,
        author: json[BookFields.author] as String,
        image: json[BookFields.image] as String,
        dateAdded: DateTime.parse(json[BookFields.date] as String),
        category:
            Category.values[int.parse(json[BookFields.category] as String)],
      );
}
