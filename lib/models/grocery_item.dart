import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;

  static GroceryItem fromFirebase(String id, dynamic data) {
    String firebaseCategory = data['category'].toString().toLowerCase();
    final Categories categoryName = Categories.values
        .firstWhere((c) => c.toString().split('.')[1] == firebaseCategory);

    return GroceryItem(
      id: id,
      name: data['name'],
      quantity: data['quantity'],
      category: categories[categoryName]!,
    );
  }
}
