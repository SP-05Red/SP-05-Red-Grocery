import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

// Stateful widget for the login page
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class for the login page
class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';

  // Flag indicating whether the user is trying to log in or register
  bool isLogin = true;

  // Controllers for email and password text fields
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // Asynchronous method to sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Asynchronous method to create a new user with email and password
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

// Widget displaying the title of the application
  Widget _title() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'GrocAgree',
        style: TextStyle(
          color: Colors.white,
          fontSize: 50.0,
        ),
      ),
    );
  }

  // Widget for creating an entry field with a title and controller
  Widget _entryField(String title, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      obscureText:
          obscureText, // Set obscureText property to true for password field
    );
  }

  // Widget for displaying error messages
  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

// Widget for creating the submit button (Login or Register)
  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Color.fromRGBO(24, 135, 239, 1),
        ),
      ),
    );
  }

// Widget for switching between Login and Register modes
  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? 'Register instead' : 'Login instead',
        style: TextStyle(color: Colors.white), // Set text color to white
      ),
    );
  }

  // Build method for the login page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('email', _controllerEmail),
            _entryField('password', _controllerPassword, obscureText: true),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
