import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (result != null) {
      setState(() {
        _groceryItems.add(result as GroceryItem);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
    final url = Uri.https(
        'flutter-shopping-list-b21da-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) return;
    final firebaseObject = json.decode(response.body) as Map<String, dynamic>;
    final list = [
      for (final entry in firebaseObject.entries)
        GroceryItem.fromFirebase(entry.key, entry.value)
    ];

    setState(() {
      _groceryItems.clear();
      _groceryItems.addAll(list);
    });
  }

  Future _deleteItem(String id) async {
    final url = Uri.https(
        'flutter-shopping-list-b21da-default-rtdb.firebaseio.com',
        'shopping-list/$id.json');
    await http.delete(url);
  }

  Future<dynamic> _showDeleteConfirmationDialog() {
    return showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          )),
    );
  }

  Future<bool> _handleDismissConfirmation(int index) async {
    final result = await _showDeleteConfirmationDialog();

    if (result) {
      await _deleteItem(_groceryItems[index].id);
      _groceryItems.removeAt(index);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(
      child: Text('No items yet'),
    );

    if (_groceryItems.isNotEmpty) {
      body = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) {
          final item = _groceryItems[index];
          return Dismissible(
            confirmDismiss: (direction) {
              return _handleDismissConfirmation(index);
            },
            onDismissed: (direction) async {},
            key: ValueKey<String>(_groceryItems[index].id),
            child: ListTile(
              title: Text(item.name),
              trailing: Text(item.quantity.toString()),
              leading: Container(
                color: item.category.color,
                width: 24,
                height: 24,
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add_a_photo),
          )
        ],
      ),
      body: body,
    );
  }
}
