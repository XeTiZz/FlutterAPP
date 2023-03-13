import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Auth {
//Creating new instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try{
      final user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    } on FirebaseAuthException catch (signUpError) {
      if(signUpError is PlatformException) {
        if(signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          /// `foo@bar.com` has alread been registered.
        }
      }
    }

    // you can also store the user in Database
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // you can also store the user in Database
  }
}

Future<bool> checkIfEmailInUse(String email) async {
  try {
    // Fetch sign-in methods for the email address
    final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    // In case list is not empty
    if (list.isNotEmpty) {
      // Return true because there is an existing
      // user using the email address
      return true;
    } else {
      // Return false because email adress is not in use
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    return true;
  }
}
