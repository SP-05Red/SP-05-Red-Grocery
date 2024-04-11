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
  final User? user = Auth().currentUser;
  bool deleteMode = false;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void toggleDeleteMode() {
    setState(() {
      deleteMode = !deleteMode;
    });
  }

  void deleteList(String listId, bool sharedList) {
    CollectionReference lists = FirebaseFirestore.instance.collection('lists');
    if (sharedList) {
      lists.doc(listId).update({
        'sharedID': FieldValue.arrayRemove([user!.email])
      });
    } else {
      lists.doc(listId).delete();
    }
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
                        if (deleteMode) {
                          deleteList(list.id, false);
                        } else {
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
                        }
                      },
                      child: ListTile(
                        title: Text(list['listName']),
                        trailing: deleteMode
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.white,
                                onPressed: () {
                                  deleteList(list.id, false);
                                },
                              )
                            : null,
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
                        if (deleteMode) {
                          deleteList(list.id, true);
                        } else {
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
                        }
                      },
                      child: ListTile(
                        title: Text(list['listName']),
                        trailing: deleteMode
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.white,
                                onPressed: () {
                                  deleteList(list.id, true);
                                },
                              )
                            : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0), // Add padding here
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(24, 135, 239, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(deleteMode ? Icons.cancel : Icons.delete),
                color: Colors.white,
                onPressed: toggleDeleteMode,
              ),
            ),
          ),
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
                  color: Color.fromRGBO(24, 135, 239, 1), // Change color here
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    String uid = user!.uid;
                    CollectionReference lists =
                        FirebaseFirestore.instance.collection('lists');
                    lists.add({
                      'UID': uid,
                      'listItems': [],
                      'listName': '',
                      'sharedID': [],
                    }).then((value) {
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
                  color: Color.fromRGBO(24, 135, 239, 1), // Change color here
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
