import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

class AuthHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;

  //create a user
  void createUser() {
    auth.createUserWithEmailAndPassword(email: 'email', password: 'password');
  }

  //log in a user

  //check current state of authentication
  void checkCurrentAuthState() {
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
      }
    });
  }
}
