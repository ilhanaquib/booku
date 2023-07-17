import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> uploadBooks(String jsonData) async {
  try {
    final List<dynamic> books = jsonDecode(jsonData);
    final collectionRef = _firestore.collection('books');
    for (var book in books) {
      final documentId = book['_id'];
      final documentRef = collectionRef.doc(documentId);
      await documentRef.set(book, SetOptions(merge: true));
      print('Updated/Added book with ID: $documentId');
    }
    print('Books uploaded successfully.');
  } catch (e) {
    print('Error uploading books: $e');
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
    await uploadBooks(jsonEncode(localBooks));

    print('Synchronization completed successfully.');
  } catch (e) {
    print('Error synchronizing with Firebase: $e');
  }
}

Future<void> downloadDataToLocalDatabase() async {
  try {
    final collectionRef = _firestore.collection('books');
    final QuerySnapshot snapshot = await collectionRef.get();

    final List<Map<String, dynamic>> downloadedData =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    final Database db = await openDatabase('books.db');
    await db.transaction((txn) async {
      await txn.delete('books');
      for (var data in downloadedData) {
        await txn.insert('books', data);
      }
    });
    await db.close();

    print('Data downloaded and stored in local database successfully.');
  } catch (e) {
    print('Error downloading data to local database: $e');
  }
}
