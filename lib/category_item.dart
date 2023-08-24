import 'package:flutter/material.dart';
import 'package:shopping_ui/models/grocery_item.dart';

class CategoryList extends StatelessWidget {
  const CategoryList(
      {required this.onDismissed, required this.groceryItem, super.key});

  final GroceryItem groceryItem;
  final void Function(DismissDirection) onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: onDismissed,
      key: ValueKey(groceryItem.id),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          color: groceryItem.category.color,
        ),
        title: Text(groceryItem.name),
        trailing: Text(
          groceryItem.quantity.toString(),
        ),
      ),
    );
  }
}
