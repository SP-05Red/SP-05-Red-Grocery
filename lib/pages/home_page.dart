import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/auth.dart';
import 'package:grocery_app/pages/add_edit_list.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/pages/search.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _deleteMode = false;

  // Current User Object retrieved from the authentication provider
  final User? user = Auth().currentUser;

  // Asynchronous method to sign out the current user
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('GrocAgree');
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        setState(() {
          _deleteMode = !_deleteMode;
        });
      },
    );
  }

  Widget _listItem(String listId, String listName, List<dynamic> sharedID) {
    return ListTile(
      title: Text(listName),
      trailing: _deleteMode
          ? IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                if (sharedID.contains(user!.email)) {
                  // If user's email is in sharedID, remove it
                  sharedID.remove(user!.email);
                  FirebaseFirestore.instance
                      .collection('lists')
                      .doc(listId)
                      .update({'sharedID': sharedID}).then((_) {
                    print('User removed from shared list successfully');
                  }).catchError((error) {
                    print('Failed to remove user from shared list: $error');
                  });
                } else {
                  // Otherwise, delete the list
                  FirebaseFirestore.instance
                      .collection('lists')
                      .doc(listId)
                      .delete()
                      .then((_) {
                    print('List deleted successfully');
                  }).catchError((error) {
                    print('Failed to delete list: $error');
                  });
                }
              },
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditListPage(
              listId: listId,
              listName: listName,
            ),
          ),
        );
      },
    );
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
                    return Column(
                      children: [
                        _listItem(list.id, list['listName'], list['sharedID']),
                        _deleteMode ? _buildDeleteButton() : Container(),
                      ],
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
                    return Column(
                      children: [
                        _listItem(list.id, list['listName'], list['sharedID']),
                        _deleteMode ? _buildDeleteButton() : Container(),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
          IconButton(
            icon: Icon(_deleteMode ? Icons.close : Icons.delete),
            onPressed: () {
              setState(() {
                _deleteMode = !_deleteMode;
              });
            },
          ),
          SizedBox(width: 10), // Add some space between the buttons
          SizedBox(
            height: 40, // Set the desired height
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(24, 135, 239, 1), // Change color here
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: signOut,
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  child: Text('Sign Out'),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40, // Set the same height as the previous button
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(24, 135, 239, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Get the current user's UID
                    String uid = user!.uid;

                    // Reference to the 'lists' collection in Firestore
                    CollectionReference lists =
                        FirebaseFirestore.instance.collection('lists');

                    // Add a new document with a generated id
                    lists.add({
                      'UID': uid,
                      'listItems': [],
                      'listName': '',
                      'sharedID': [],
                    }).then((value) {
                      // Navigate to AddEditListPage passing the newly generated list's document ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddEditListPage(listId: value.id)),
                      );
                    }).catchError(
                        (error) => print("Failed to add list: $error"));
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40, // Set the same height as the previous buttons
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(24, 135, 239, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ),
            ),
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
