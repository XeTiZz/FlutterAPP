// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

import 'auth.dart';
import 'register.dart';
import 'package:todo_tasks_with_alert/layout/todo_layout.dart';

bool connected = false;
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  
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
  bool _loading1 = false;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    setState(() => _loading = true);

    //Check if is login or register
    try{
      if (isLogin) {
        await Auth().registerWithEmailAndPassword(email, password);
        connected = true;
      } else {
        await Auth().signInWithEmailAndPassword(email, password);
        connected = true;
      }
      setState(() => _loading = false);
    }on FirebaseAuthException catch (e) {
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
    // print("ICIIIIIIIIII "+_user!.uid);
    List<Map<String, dynamic>> events = await getAllEvents();
    if(events.isEmpty){
      // Effectuer une requête sur Firebase en fonction de l'ID de l'utilisateur
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference users = firestore.collection('note');
      final QuerySnapshot querySnapshot = await users.where('idUser', isEqualTo: _user!.uid).get();
      final List<QueryDocumentSnapshot> noteDocs = querySnapshot.docs;

      final sqliteDb = await openDatabase('todo.db');
      // Parcourir les documents pour récupérer les données de l'utilisateur
      for (var noteDoc in noteDocs) {
        Map<String, Object?> data = Map.from(noteDoc.data() as Map<String, Object?>);
        data.remove('idDB');
        data.remove('idUser');
        await sqliteDb.insert('events', data);
      }
    }else{

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
                  "Connexion",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.deepOrange),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
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
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            ),
                        child: _loading1
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Créer un compte'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    connected = true;
                    final GoogleSignInAccount? googleUser =
                        await GoogleSignIn().signIn();
                    final GoogleSignInAuthentication? googleAuth =
                        await googleUser?.authentication;
                    final AuthCredential credential =
                        GoogleAuthProvider.credential(
                      accessToken: googleAuth?.accessToken,
                      idToken: googleAuth?.idToken,
                    );
                    final UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithCredential(
                            credential);
                    final User? user = userCredential.user;
                    // continue with your app logic
                  },
                  child: Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                  ),
                ),
              //   TextButton(
              //   onPressed: () async {
              //      // récupérez l'e-mail de l'utilisateur
              //     await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
              //     // affichez un message à l'utilisateur pour lui indiquer que le lien de réinitialisation a été envoyé
              //   },
              //   child: Text('Mot de passe oublié'),
              // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}