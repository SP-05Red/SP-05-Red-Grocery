import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  // Current User Object retrieved from the authentication provider
  final User? user = Auth().currentUser;

  // Asynchronous method to sign out the current user
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('GrocAgree');
  }

  // Widget representing the user's personal lists
  Widget _myLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 150, // Adjust the height as needed
          child: ListView.builder(
            itemCount: 0, // Add the number of items when available
            itemBuilder: (context, index) {
              // Build your list items here
              return ListTile(
                title: Text('List Item $index'),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget representing the shared lists of the user
  Widget _sharedLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shared Lists',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 150, // Adjust the height as needed
          child: ListView.builder(
            itemCount: 0, // Add the number of items when available
            itemBuilder: (context, index) {
              // Build your list items here
              return ListTile(
                title: Text('Shared List Item $index'),
              );
            },
          ),
        ),
      ],
    );
  }

  // Build method for the home page and its UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
          TextButton(
            onPressed: signOut,
            child: Text('Sign Out'),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add button pressed, add functionality here.
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search button pressed, add functionality here.
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _myLists(),
            SizedBox(height: 20),
            _sharedLists(),
          ],
        ),
      ),
    );
  }
}
