import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('GrocAgree');
  }

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
