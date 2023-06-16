import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) {
          final item = groceryItems[index];
          return ListTile(
            title: Text(item.name),
            trailing: Text(item.quantity.toString()),
            leading: Container(
              color: item.category.color,
              width: 24,
              height: 24,
            ),
          );
        },
      ),
    );
  }
}
