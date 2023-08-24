import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_ui/data/categories.dart';
import 'package:shopping_ui/models/category.dart';
import 'package:shopping_ui/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _value = categories[Categories.vegetables]!;
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _isSending = false;

  Future _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-prep-60349-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'content-type': 'application/json',
        },
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _value.title,
        }),
      );
      final Map<String, dynamic> decodedItem = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
          id: decodedItem['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _value,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Item name'),
                validator: (value) {
                  if (value!.isEmpty || value.trim().length <= 1) {
                    return 'Must be between 2 to 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value!.isEmpty || int.tryParse(value)! <= 1) {
                          return 'Please input a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _value,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 10),
                                Text(category.value.title)
                              ],
                            ),
                          )
                      ],
                      onChanged: ((value) {
                        _value = value!;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: _isSending
                    ? null
                    : () {
                        _submitForm();
                      },
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text('Submit Form'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isSending
                    ? null
                    : () {
                        _formKey.currentState!.reset();
                      },
                child: const Text('Reset Form'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
