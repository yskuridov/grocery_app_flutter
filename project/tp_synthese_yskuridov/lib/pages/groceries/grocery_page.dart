import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/models/grocery.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';

import '../../providers/groceries_provider.dart';
import '../../providers/groups_provider.dart';

class GroceryPage extends StatefulWidget {
  final Grocery grocery;

  const GroceryPage(this.grocery);

  @override
  _GroceryPageState createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  late List<Product> products;

  @override
  void initState() {
    super.initState();
    products = widget.grocery.products;
  }

  @override
  Widget build(BuildContext context) {
    final groceryProvider = Provider.of<GroceryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grocery.name),
      ),
      body: products.isEmpty
          ? const Center(
              child: Text(
                "Cette épicerie ne contient pas encore de produits, veuillez en ajouter pour continuer",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final Product movedProduct =
                            products.removeAt(oldIndex);
                        products.insert(newIndex, movedProduct);
                        groceryProvider.updateProductOrder(
                            widget.grocery.id, products);
                      });
                    },
                    children: List.generate(
                      products.length,
                      (index) {
                        final Product product = products[index];
                        return ListTile(
                          key: Key(product.id),
                          tileColor: product.isMissing
                              ? Colors.red[100]
                              : product.boughtOn != null
                                  ? Colors.teal[100]
                                  : Colors.grey[100],
                          leading: Image.network(
                            product.imageUrl,
                            fit: BoxFit.fill,
                            width: 75,
                            height: 75,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: product.boughtOn != null
                              ? Text(
                                  'Acheté le: ${_formatDate(product.boughtOn!)}',
                                )
                              : product.isMissing
                                  ? const Text("Article manquant")
                                  : const Text("À acheter"),
                          trailing:
                              (product.boughtOn == null && !product.isMissing)
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_shopping_cart,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            groceryProvider.setItemAsMissing(
                                                widget.grocery.id, product);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () {
                                            groceryProvider.setItemAsBought(
                                                widget.grocery.id, product);
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddGroupDialog(context, groceryProvider);
                  },
                  child: const Text('Ajouter un groupe à l\'épicerie'),
                ),
              ],
            ),
    );
  }

  void _showAddGroupDialog(
      BuildContext context, GroceryProvider groceryProvider) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accès à l\'épicerie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: groupProvider.userGroups.length,
                  itemBuilder: (context, index) {
                    final group = groupProvider.userGroups[index];
                    return ListTile(
                      title: Text(group.name),
                      trailing: widget.grocery.groupsIds.contains(group.id)
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                groceryProvider.removeGroupFromGrocery(
                                    widget.grocery.id, group.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Supprimer'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                groceryProvider.addGroupToGrocery(
                                    group.id, widget.grocery.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ajouter'),
                            ),
                    );
                  },
                ),
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
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }
}
