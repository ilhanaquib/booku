// this is a firebase helper for uploading data from sqflite to firebase and downloading from firebase to sqflite

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:booku/models/books_model.dart';
import 'dart:convert';
import 'dart:io';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> uploadBooks(String jsonData) async {
  try {
    final List<dynamic> books = jsonDecode(jsonData);
    final collectionRef = _firestore.collection('books');

    for (var book in books) {
      final documentId = book['_id'];

      // Check if the book has an image path
      if (book['_image'] != null && book['_image'] is String) {
        // Upload the image file to Firebase Storage
        final imagePath = book['_image'];
        final imageName = documentId;
        final imageFile = File(imagePath);
        final imageURL = await uploadImageToStorage(imageFile, imageName);

        if (imageURL != null) {
          // Store the image download URL in the book document
          book['_imageURL'] = imageURL;
        }
      }

      final documentRef = collectionRef.doc(documentId);
      await documentRef.set(book, SetOptions(merge: true));
      print('Updated/Added book with ID: $documentId');
    }

    print('Books uploaded successfully.');
  } catch (e) {
    print('Error uploading books: $e');
  }
}

Future<String?> uploadImageToStorage(File imageFile, String imageName) async {
  print('Uploading image: $imageName');
  try {
    final storageRef =
        storage.FirebaseStorage.instance.ref().child('book_images/$imageName');
    final uploadTask = storageRef.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    return await taskSnapshot.ref.getDownloadURL();
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}

Future<String> convertToJSON(List<Map<String, dynamic>> data) async {
  return jsonEncode(data);
}

Future<List<Map<String, dynamic>>> getBooksFromLocalDatabase() async {
  final Database db =
      await openDatabase('books.db'); // Replace with your database file path
  final List<Map<String, dynamic>> books =
      await db.query('books'); // Replace with your table name
  return books;
}

Future<void> synchronizeWithFirebase() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Get books from local database
    final List<Map<String, dynamic>> localBooks =
        await getBooksFromLocalDatabase();
    final Set<String> localBookIds = localBooks
        .map((book) => book['id']?.toString())
        .whereType<String>()
        .toSet();

    // Get books from Firebase
    final QuerySnapshot snapshot = await _firestore.collection('books').get();
    final List<QueryDocumentSnapshot> firebaseBooks = snapshot.docs;
    final Set<String> firebaseBookIds =
        firebaseBooks.map((doc) => doc.id).toSet();

    // Compare local and Firebase books
    final Set<String> booksToDelete = firebaseBookIds.difference(localBookIds);

    // Delete books from Firebase
    final WriteBatch batch = _firestore.batch();
    for (var bookId in booksToDelete) {
      final documentRef = _firestore.collection('books').doc(bookId);
      batch.delete(documentRef);
      print('Deleted book with ID: $bookId');
    }
    await batch.commit();

    // Upload local books to Firebase
    final String jsonData = await convertToJSON(localBooks);
    await uploadBooks(jsonData);

    print('Synchronization completed successfully.');
  } catch (e) {
    print('Error synchronizing with Firebase: $e');
  }
}

Future<void> downloadDataToLocalDatabase() async {
  try {
    final collectionRef = _firestore.collection('books');
    final QuerySnapshot snapshot = await collectionRef.get();

    final List<Map<String, dynamic>> downloadedData = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final imageURL = data['_imageURL'];

      // Download the image file from Firebase Storage and get its local path
      if (imageURL != null && imageURL is String) {
        final imageFile = await downloadImageFromStorage(imageURL);
        if (imageFile != null) {
          data['image'] = imageFile.path;
        }
      }

      downloadedData.add(data);
    }

    final Database db = await openDatabase('books.db');
    await db.transaction((txn) async {
      await txn.delete('books');
      for (var data in downloadedData) {
        await txn.insert('books', data);
      }
    });

    print('Data downloaded and stored in the local database successfully.');
  } catch (e) {
    print('Error downloading data to the local database: $e');
  }
}

Future<File?> downloadImageFromStorage(String imageURL) async {
  try {
    final ref = storage.FirebaseStorage.instance.refFromURL(imageURL);
    final bytes = await ref.getData();
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(
        directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final file = File(filePath);
    await file.writeAsBytes(bytes!);
    return file;
  } catch (e) {
    print('Error downloading image: $e');
    return null;
  }
}

Future<List<Book>> getBooksFromFirestore() async {
  try {
    final QuerySnapshot snapshot = await _firestore.collection('books').get();
    final List<QueryDocumentSnapshot> bookDocs = snapshot.docs;
    final List<Book> books = [];

    for (var doc in bookDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final imageUrl = data['_imageURL']
          as String?; // Assuming you have 'imageURL' field in Firestore

      final book = Book(
        id: data[BookFields.id] as String,
        title: data[BookFields.title] as String,
        author: data[BookFields.author] as String,
        image: data[BookFields.image] as String,
        dateAdded: DateTime.parse(data[BookFields.date] as String),
        category:
            Category.values[int.parse(data[BookFields.category] as String)],
        imageUrl: imageUrl ?? '',
      );
      books.add(book);
    }

    return books;
  } catch (e) {
    print('Error getting books from Firestore: $e');
    return [];
  }
}
