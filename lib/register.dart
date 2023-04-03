// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_tasks_with_alert/login.dart';

import 'auth.dart';
import 'package:todo_tasks_with_alert/layout/todo_layout.dart';
bool connected = false;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TodoLayout(connected: connected); //TodoLayout()
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    setState(() => _loading = true);

    try{
    //Check if is login or register
    if (isLogin) {
      await Auth().signInWithEmailAndPassword(email, password);
      connected = true;
    } else {
      await Auth().registerWithEmailAndPassword(email, password);
      connected = true;
    }
    setState(() => _loading = false);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'E-mail ou mot de passe invalide';
        setState(() => _loading = false);
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'L\'e-mail est déjà utilisé';
        setState(() => _loading = false);
      } else {
        errorMessage = 'Une erreur est survenue. Essayer plus tard.';
        setState(() => _loading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    
    Future<List<Map<String, dynamic>>> getAllEvents() async {
      final db = await openDatabase('todo.db');
      final List<Map<String, dynamic>> maps = await db.query('events');
      return maps;
    }

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final User? _user = FirebaseAuth.instance.currentUser;

    List<Map<String, dynamic>> events = await getAllEvents();

    // Parcourir les événements et ajouter chaque événement dans Firestore
    for (var event in events) {
      Map<String, dynamic> note = {
        'title': event['title'],
        'date': event['date'], 
        'starttime': event['starttime'],
        'endtime': event['endtime'],
        'status': event['status'],
        'remind': event['remind'],
        'idUser': _user!.uid,
        'idDB': event['id'],
      };

      db.collection('note').add(note)
      .then((documentReference) {
        print('Document added with ID: ${documentReference.id}');
      });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            //Add form to key to the Form Widget
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Inscription",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,color: Colors.deepOrange),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  //Assign controller
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez une adresse mail';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  //Assign controller
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez un mot de passe';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Mot de passe',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  onPressed: () => handleSubmit(),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Connexion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}