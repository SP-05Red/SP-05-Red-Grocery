import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/pages/add_edit_list.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Lists'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search lists...',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lists')
                  .where('UID',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final lists = snapshot.data!.docs;
                  final searchText = _searchController.text.toLowerCase();

                  // Filter the lists based on the search text
                  final filteredLists = lists.where((list) {
                    final listName = list['listName'].toString().toLowerCase();
                    final listItems = list['listItems']
                        .toString()
                        .toLowerCase()
                        .contains(searchText);
                    return listName.contains(searchText) || listItems;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredLists.length,
                    itemBuilder: (context, index) {
                      final list = filteredLists[index];
                      return ListTile(
                        title: Text(list['listName']),
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
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListDetailPage extends StatelessWidget {
  final String listId;

  const ListDetailPage({Key? key, required this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch list details using listId and display here
    return Scaffold(
      appBar: AppBar(
        title: Text('List Details'),
      ),
      body: Center(
        child: Text('List Details for $listId'),
      ),
    );
  }
}
