import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp_synthese_yskuridov/pages/products/product_page.dart';
import 'package:tp_synthese_yskuridov/providers/product_provider.dart';
import 'package:tp_synthese_yskuridov/models/product.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  final categoryController = TextEditingController();

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: true);
    categoryController.text.isEmpty
        ? products = productProvider.products
        : null;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Articles d\'épicerie',
            style: TextStyle(fontSize: 18, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Filtrer par catégorie"),
                onChanged: filterProducts,
              )),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final Product product = products[index];
                return ListTile(
                  tileColor: Colors.grey[100],
                  leading: Image.network(
                    fit: BoxFit.fill,
                    product.imageUrl,
                    width: 75,
                    height: 50,
                  ),
                  title: Text(product.name),
                  subtitle: Text(product.category),
                  trailing: product.addedBy ==
                          FirebaseAuth.instance.currentUser!.email
                      ? const Icon(
                          Icons.account_circle,
                          color: Colors.teal,
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showCreateArticleDialog(context);
                },
                child: const Text('Ajouter un produit'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showCreateFromCupCodeDialog(context);
                },
                child: const Text('Ajouter par code CUP'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void filterProducts(String category) {
    final filteredProducts = products
        .where((product) =>
            product.category.toLowerCase().contains(category.toLowerCase()))
        .toList();
    setState(() => products = filteredProducts);
  }

  void _showCreateArticleDialog(BuildContext context) {
    void _addProduct(String name, String category, String imageUrl) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.createProduct(name, category, imageUrl);
    }

    bool _imageIsValid(String imageUrl) {
      final image = imageUrl.split('.');
      if (image[image.length - 1] != 'jpg' &&
          image[image.length - 1] != 'png') {
        return false;
      }
      return true;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String category = '';
        String imageUrl = '';

        return AlertDialog(
          title: const Text('Ajouter un article'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration:
                    const InputDecoration(hintText: 'Nom de l\'article'),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  category = value;
                },
                decoration: const InputDecoration(hintText: 'Catégorie'),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  imageUrl = value;
                },
                decoration: const InputDecoration(hintText: 'URL de l\'image'),
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
              child: const Text('Ajouter'),
              onPressed: () {
                (name == '' || category == '' || !_imageIsValid(imageUrl))
                    ? _showSnackbar(
                        'Veuillez remplir tous les champs et fournir une image .jpg ou .png')
                    : {
                        _addProduct(name, category, imageUrl),
                        Navigator.of(context).pop(),
                      };
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateFromCupCodeDialog(BuildContext context) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#008080',
      'Annuler',
      false,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      productProvider.createProductFromCupCode(barcodeScanRes);
      _showSnackbar('Article ajouté');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
