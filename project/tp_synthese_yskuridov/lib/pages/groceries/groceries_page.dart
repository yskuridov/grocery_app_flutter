import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/providers/groceries_provider.dart';
import 'package:tp_synthese_yskuridov/models/grocery.dart';
import './grocery_page.dart';
import 'package:intl/intl.dart';

class GroceriesPage extends StatelessWidget {
  const GroceriesPage({Key? key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GroceryProvider>(
        builder: (context, groceryProvider, _) {
          var userGroups = groceryProvider.groceries;
          return Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Mes épiceries',
                style: TextStyle(fontSize: 18, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: userGroups.length,
                  itemBuilder: (context, index) {
                    final Grocery grocery = userGroups[index];
                    return ListTile(
                      tileColor: grocery.isActive
                          ? Colors.teal[100]
                          : Colors.grey[100],
                      trailing: grocery.isActive
                          ? const Text(
                              'Active',
                              style: TextStyle(color: Colors.teal),
                            )
                          : null,
                      title: Text(
                        grocery.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_formatDate(grocery.date)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroceryPage(grocery),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGroceryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  void _showCreateGroceryDialog(BuildContext context) {
    String groceryName = '';
    DateTime selectedDate = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Créer une épicerie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  groceryName = value;
                },
                decoration:
                    const InputDecoration(hintText: 'Nom de l\'épicerie'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Créer'),
              onPressed: () {
                final groceryProvider =
                    Provider.of<GroceryProvider>(context, listen: false);
                groceryProvider.createGrocery(groceryName, selectedDate);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
