// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth.dart';
import 'register.dart';
import 'package:todo_tasks_with_alert/layout/todo_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TodoLayout(); //TodoLayout()
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
    if (isLogin) {
      await Auth().registerWithEmailAndPassword(email, password);
    } else {
      await Auth().signInWithEmailAndPassword(email, password);
    }

    setState(() => _loading = false);
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),selectionColor: Colors.black,
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
                          backgroundColor: Colors.black,
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
                          backgroundColor: Colors.black,
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
                  child: Text('Connect with Google'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}