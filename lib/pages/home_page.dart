import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/auth.dart';
import 'package:grocery_app/pages/add_edit_list.dart';
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
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lists')
              .where('UID', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final lists = snapshot.data!.docs;
              return Container(
                height: 150,
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditListPage(
                              listId: list.id,
                              listName: list['listName'],
                              listItems: list['listItems'].join('\n'),
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(list['listName']),
                      ),
                    );
                  },
                ),
              );
            }
          },
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
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lists')
              .where('sharedID', arrayContains: user!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final lists = snapshot.data!.docs;
              return Container(
                height: 150,
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditListPage(
                              listId: list.id,
                              listName: list['listName'],
                              listItems: list['listItems'].join('\n'),
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(list['listName']),
                      ),
                    );
                  },
                ),
              );
            }
          },
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditListPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
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
