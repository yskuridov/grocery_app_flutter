import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';
import '../../providers/groceries_provider.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  color: Colors.teal,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.category,
                style:
                    const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              Text(
                'Ajouté par ${product.addedBy}',
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Set the border color
                    width: 1.0, // Set the border width
                  ),
                ),
                child: Image.network(
                  product.imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 20),
              (product.nutritionFacts != null &&
                      product.nutritionFacts!.isNotEmpty)
                  ? Column(
                      children: [
                        const Text(
                          'Informations nutritionnelles',
                          style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.teal),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: product.nutritionFacts!
                              .split(', ')
                              .where((fact) => fact.trim().isNotEmpty)
                              .map((fact) {
                            return Text(
                              fact,
                              style: const TextStyle(fontSize: 14),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : const SizedBox(height: 0),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final groceryProvider =
                      Provider.of<GroceryProvider>(context, listen: false);
                  final groceries = groceryProvider.groceries;
                  if (groceries.isEmpty) {
                    final newGroceryName = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        String name = '';

                        return AlertDialog(
                          title: const Text(
                              'Créez une épicerie avant d\'ajouter un article'),
                          content: TextField(
                            onChanged: (value) {
                              name = value;
                            },
                            decoration: const InputDecoration(
                                hintText: 'Nom de l\'épicerie'),
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
                                if (name.isNotEmpty) {
                                  Navigator.of(context).pop(name);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (newGroceryName != null) {
                      await groceryProvider.createGrocery(
                          newGroceryName, DateTime.now());
                      await groceryProvider.addProductToGrocery(product);
                      showSnackbar("Épicerie créée et produit ajouté");
                    }
                  } else {
                    final lengthBeforeAdding = groceries.first.products.length;
                    await groceryProvider.addProductToGrocery(product);
                    if (lengthBeforeAdding < groceries.first.products.length) {
                      showSnackbar("Produit ajouté à l'épicerie en cours");
                    } else {
                      showSnackbar(
                          "Le produit est déjà dans l'épicerie en cours");
                    }
                  }
                },
                child: const Text('Ajouter à l\'épicerie en cours'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
