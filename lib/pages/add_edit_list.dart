import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/auth.dart';

class AddEditListPage extends StatelessWidget {
  final String? listId;
  final String? listName;
  final String? listItems;

  AddEditListPage({this.listId, this.listName, this.listItems});

  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _listItemsController = TextEditingController();
  final TextEditingController _sharedIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pre-fill text fields if editing an existing list in Firestore
    if (listName != null) _listNameController.text = listName!;
    if (listItems != null) _listItemsController.text = listItems!;

    return Scaffold(
      appBar: AppBar(
        title: Text(listId != null ? 'Edit List' : 'Add List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _listNameController,
              decoration: const InputDecoration(labelText: 'List Name'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                controller: _listItemsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'List Items',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Shared with:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSharedUsersList(context),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addOtherUsers(context);
              },
              child: const Text('Share with other users'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveListToFirestore(context, _sharedIdController.text.trim());
              },
              child: Text(listId != null ? 'Update List' : 'Save List'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedUsersList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .doc(listId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container();
        }
        List<dynamic> sharedUsers = snapshot.data!.get('sharedID') ?? [];
        // Filter out empty sharedID fields
        sharedUsers = sharedUsers.where((id) => id.isNotEmpty).toList();
        return sharedUsers.isEmpty
            ? const Text('No users shared with')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: sharedUsers.length,
                itemBuilder: (context, index) {
                  final String sharedId = sharedUsers[index];
                  return ListTile(
                    title: Text(sharedId),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove,
                          color: Colors.red), // Set icon color to red
                      onPressed: () {
                        _removeSharedIdFromFirestore(context, sharedId);
                      },
                    ),
                  );
                },
              );
      },
    );
  }

  Future<void> _removeSharedIdFromFirestore(
      BuildContext context, String sharedId) async {
    try {
      if (listId != null) {
        await FirebaseFirestore.instance
            .collection('lists')
            .doc(listId)
            .update({
          'sharedID': FieldValue.arrayRemove([sharedId])
        });
      }
    } catch (error) {
      print('Error removing shared ID: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing shared ID')),
      );
    }
  }

  Future<void> _addOtherUsers(BuildContext context) async => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Additional Options'),
            content: TextField(
              controller: _sharedIdController,
              decoration: const InputDecoration(labelText: 'Enter User Email'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Exit'),
              ),
              TextButton(
                onPressed: () {
                  _saveSharedIdToFirestore(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

  Future<void> _saveSharedIdToFirestore(BuildContext context) async {
    try {
      String sharedId = _sharedIdController.text.trim();
      if (sharedId.isNotEmpty) {
        if (listId != null) {
          await FirebaseFirestore.instance
              .collection('lists')
              .doc(listId)
              .update({
            'sharedID': FieldValue.arrayUnion([sharedId])
          });
        }
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter User Email')),
        );
      }
    } catch (error) {
      print('Error saving shared ID: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving shared ID')),
      );
    }
  }

  Future<void> _saveListToFirestore(
      BuildContext context, String sharedID) async {
    try {
      String listName = _listNameController.text.trim();
      String listItemsText = _listItemsController.text.trim();
      if (listName.isNotEmpty && listItemsText.isNotEmpty) {
        if (listId != null) {
          // If listId is not null, it means we are editing an existing list
          DocumentSnapshot listSnapshot = await FirebaseFirestore.instance
              .collection('lists')
              .doc(listId)
              .get();

          if (listSnapshot.exists) {
            String originalUID = listSnapshot.get('UID');

            List<dynamic> currentSharedIDs = listSnapshot.get('sharedID') ?? [];
            currentSharedIDs.remove(sharedID);
            currentSharedIDs.add(sharedID);

            List<String> listItems = listItemsText.split('\n');
            Map<String, dynamic> listData = {
              'UID': originalUID,
              'listName': listName,
              'listItems': listItems,
              'sharedID': currentSharedIDs,
            };
            await FirebaseFirestore.instance
                .collection('lists')
                .doc(listId)
                .update(listData);
          }
        } else {
          // If listId is null, it means we are creating a new list
          Auth auth = Auth();
          String uid = auth.currentUser!.uid;

          String newlistId =
              FirebaseFirestore.instance.collection('lists').doc().id;
          List<String> listItems = listItemsText.split('\n');
          Map<String, dynamic> listData = {
            'UID': uid,
            'listName': listName,
            'listItems': listItems,
            'sharedID': [sharedID],
          };
          await FirebaseFirestore.instance
              .collection('lists')
              .doc(newlistId)
              .set(listData);
        }

        // Navigate back to the previous screen
        Navigator.pop(context);
      } else {
        // Show an error message if the list name or items are empty
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('List name and items cannot be empty')));
      }
    } catch (error) {
      // Handle errors
      print('Error saving list: $error');
      // Show an error message
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error saving list')));
    }
  }
}
