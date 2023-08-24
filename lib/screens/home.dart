import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_ui/category_item.dart';
import 'package:shopping_ui/data/categories.dart';
import 'package:shopping_ui/models/category.dart';
import 'package:shopping_ui/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_ui/screens/new_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, super.key});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  Future _loaditems() async {
    final url = Uri.https(
        'flutter-prep-60349-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> decodedItem = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in decodedItem.entries) {
      final category = categories.entries.firstWhere(
        (catItem) => catItem.value.title == item.value['category'],
      );
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category.value,
        ),
      );
    }
    setState(() {
      _groceryItem = loadedItems;
      _isLoading = false;
    });
  }

  Future _formPage() async {
    final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} is removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItem.insert(index, item);
            });
          },
        ),
      ),
    );
    final url = Uri.https('flutter-prep-60349-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error deleting ${item.name}. Please check your internet connection and try again'),
        ),
      );
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: CircularProgressIndicator(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? mainContent
          : ListView.builder(
              itemCount: _groceryItem.length,
              itemBuilder: (context, index) {
                return CategoryList(
                  groceryItem: _groceryItem[index],
                  onDismissed: (direction) {
                    _removeItem(
                      _groceryItem[index],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _formPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
